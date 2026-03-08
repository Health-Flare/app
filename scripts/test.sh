#!/usr/bin/env bash
#
# Health Flare Test Runner
# ========================
# A human-friendly test runner for the Health Flare app.
#
# Usage:
#   ./scripts/test.sh              # Run all tests
#   ./scripts/test.sh unit         # Run unit tests only
#   ./scripts/test.sh widget       # Run widget tests only
#   ./scripts/test.sh bdd          # Run BDD tests only
#   ./scripts/test.sh integration  # Run integration tests
#   ./scripts/test.sh --coverage   # Run all tests with coverage
#   ./scripts/test.sh --watch      # Run tests in watch mode
#   ./scripts/test.sh --help       # Show this help
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Show help
show_help() {
    cat << EOF
Health Flare Test Runner
========================

Usage: ./scripts/test.sh [command] [options]

Commands:
  (none)         Run all tests
  unit           Run unit tests only (test/unit/)
  widget         Run widget tests only (test/widget/)
  bdd            Run BDD/feature tests (test/bdd/)
  integration    Run integration tests (integration_test/)
  all            Run all tests including integration

Options:
  --coverage     Generate code coverage report
  --watch        Run tests in watch mode (re-runs on file changes)
  --verbose      Show verbose output
  --update       Update golden files (for widget tests)
  --help         Show this help message

Examples:
  ./scripts/test.sh                    # Run all unit/widget/bdd tests
  ./scripts/test.sh unit --coverage    # Run unit tests with coverage
  ./scripts/test.sh widget --watch     # Watch mode for widget tests
  ./scripts/test.sh --coverage         # All tests with coverage report

Coverage Report:
  After running with --coverage, open coverage/html/index.html to view
  the detailed coverage report in your browser.

EOF
}

# Parse arguments
COMMAND=""
COVERAGE=false
WATCH=false
VERBOSE=false
UPDATE_GOLDENS=false

for arg in "$@"; do
    case $arg in
        unit|widget|bdd|integration|all)
            COMMAND=$arg
            ;;
        --coverage)
            COVERAGE=true
            ;;
        --watch)
            WATCH=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
        --update)
            UPDATE_GOLDENS=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown argument: $arg"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Build flutter test command
build_test_command() {
    local test_path=$1
    local cmd="flutter test"

    if [ -n "$test_path" ]; then
        cmd="$cmd $test_path"
    fi

    if [ "$COVERAGE" = true ]; then
        cmd="$cmd --coverage"
    fi

    if [ "$VERBOSE" = true ]; then
        cmd="$cmd --reporter=expanded"
    fi

    if [ "$UPDATE_GOLDENS" = true ]; then
        cmd="$cmd --update-goldens"
    fi

    echo "$cmd"
}

# Run tests
run_tests() {
    local test_path=$1
    local description=$2

    print_header "$description"

    local cmd=$(build_test_command "$test_path")
    echo "Running: $cmd"
    echo ""

    if eval "$cmd"; then
        print_success "All tests passed!"
        return 0
    else
        print_error "Some tests failed"
        return 1
    fi
}

# Watch mode
run_watch() {
    local test_path=$1
    print_header "Watch Mode - $test_path"
    print_warning "Press Ctrl+C to stop"
    echo ""

    # Use flutter test with watch if available, otherwise use a simple loop
    if command -v fswatch &> /dev/null; then
        fswatch -o lib/ test/ | while read; do
            clear
            flutter test $test_path --reporter=expanded || true
        done
    else
        print_warning "fswatch not found. Using polling (every 2 seconds)..."
        while true; do
            clear
            flutter test $test_path --reporter=expanded || true
            sleep 2
        done
    fi
}

# Generate coverage report
generate_coverage_report() {
    if [ "$COVERAGE" = true ]; then
        print_header "Generating Coverage Report"

        if command -v lcov &> /dev/null; then
            # Generate HTML report
            genhtml coverage/lcov.info -o coverage/html --quiet
            print_success "Coverage report generated: coverage/html/index.html"

            # Show summary
            echo ""
            lcov --summary coverage/lcov.info 2>/dev/null || true

            # Open in browser on macOS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo ""
                read -p "Open coverage report in browser? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    open coverage/html/index.html
                fi
            fi
        else
            print_warning "lcov not installed. Install with: brew install lcov"
            print_warning "Raw coverage data available in: coverage/lcov.info"
        fi
    fi
}

# Main execution
main() {
    # Ensure we're in the project root
    cd "$(dirname "$0")/.."

    # Check flutter is available
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter first."
        exit 1
    fi

    # Watch mode
    if [ "$WATCH" = true ]; then
        case $COMMAND in
            unit)
                run_watch "test/unit/"
                ;;
            widget)
                run_watch "test/widget/"
                ;;
            bdd)
                run_watch "test/bdd/"
                ;;
            *)
                run_watch "test/"
                ;;
        esac
        exit 0
    fi

    # Normal test execution
    local exit_code=0

    case $COMMAND in
        unit)
            run_tests "test/unit/" "Unit Tests" || exit_code=1
            ;;
        widget)
            run_tests "test/widget/" "Widget Tests" || exit_code=1
            ;;
        bdd)
            run_tests "test/bdd/" "BDD Feature Tests" || exit_code=1
            ;;
        integration)
            print_header "Integration Tests"
            print_warning "Integration tests require a running emulator/simulator"
            echo ""
            flutter test integration_test/ --reporter=expanded || exit_code=1
            ;;
        all)
            run_tests "test/unit/" "Unit Tests" || exit_code=1
            run_tests "test/widget/" "Widget Tests" || exit_code=1
            run_tests "test/bdd/" "BDD Feature Tests" || exit_code=1
            print_header "Integration Tests"
            print_warning "Integration tests require a running emulator/simulator"
            flutter test integration_test/ --reporter=expanded || exit_code=1
            ;;
        *)
            # Default: run unit, widget, and bdd tests
            run_tests "" "All Tests (Unit + Widget + BDD)" || exit_code=1
            ;;
    esac

    generate_coverage_report

    echo ""
    if [ $exit_code -eq 0 ]; then
        print_success "All test suites completed successfully!"
    else
        print_error "Some tests failed. See output above for details."
    fi

    exit $exit_code
}

main
