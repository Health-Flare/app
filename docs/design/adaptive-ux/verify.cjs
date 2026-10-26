// Browser review checks only. Not Flutter or native device acceptance tests.
// PLAYWRIGHT_MODULE=/path/to/playwright node verify.cjs
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
(async () => {
  const browser = await chromium.launch({ channel: process.env.BROWSER_CHANNEL || 'chrome', headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 1100 } });
  const errors = [], network = [], results = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('request', r => { if (/^https?:/.test(r.url())) network.push(r.url()); });
  const check = async (name, f) => { await f(); results.push({ name, result: 'pass' }); };
  const state = () => page.evaluate(() => window.reviewState());
  const shot = name => page.screenshot({ path: path.join(__dirname, name + '.png'), fullPage: true });
  await page.goto('file://' + path.join(__dirname, 'index.html'));
  await page.evaluate(() => document.fonts.ready);
  await check('Bundled fonts load offline', async () => {
    assert(await page.evaluate(() => ['DMSans', 'Fraunces', 'DMMono'].every(f => document.fonts.check('16px ' + f))));
  });
  await check('Recommended tablet uses contextual panes', async () => {
    assert(await page.locator('#app').evaluate(e => e.classList.contains('wide')));
    assert.equal((await state()).selected, 'a1');
    await shot('01-tablet-context');
  });
  await check('Select and edit retain draft, focus and caret on real resize', async () => {
    await page.locator('[data-id="a2"]').click();
    await page.locator('#edit').click();
    await page.locator('#title').fill('Synthetic changed title');
    await page.locator('#title').evaluate(e => e.setSelectionRange(3, 8));
    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForFunction(() => !document.querySelector('#app').classList.contains('wide'));
    assert.equal(await page.locator('#title').inputValue(), 'Synthetic changed title');
    assert.equal(await page.evaluate(() => document.activeElement.id), 'title');
    assert.deepEqual(await page.locator('#title').evaluate(e => [e.selectionStart, e.selectionEnd]), [3, 8]);
    assert.equal((await state()).saveCount, 0);
    assert.equal((await state()).records.find(x => x.id === 'a2').title, 'Follow-up visit');
    assert.equal(await page.locator('#app').evaluate(e => e.classList.contains('wide')), false);
    await shot('02-compact-edit');
    await page.setViewportSize({ width: 1440, height: 1100 });
  });
  await check('Duo controls share layout and never save on transition', async () => {
    await page.locator('#directions [data-direction="fold"]').click();
    for (let i = 0; i < 3; i++) {
      await page.getByRole('button', { name: 'Duo closed', exact: true }).click();
      await page.getByRole('button', { name: 'Duo open', exact: true }).click();
    }
    assert.equal((await state()).saveCount, 0);
    assert.equal((await state()).draft.title, 'Synthetic changed title');
    await shot('03-duo-open-draft');
    await page.getByRole('button', { name: 'Duo closed', exact: true }).click();
    await shot('04-duo-closed-draft');
  });
  await check('Explicit save updates only selected record once', async () => {
    await page.getByRole('button', { name: 'Save', exact: true }).click();
    const s = await state();
    assert.equal(s.saveCount, 1);
    assert.equal(s.records.find(x => x.id === 'a2').title, 'Synthetic changed title');
    assert.equal(s.records.find(x => x.id === 'b1').title, 'Demo B appointment');
    assert.equal(await page.locator('#detail-heading').textContent(), 'Synthetic changed title');
  });
  await check('Invalid input retains draft and original record', async () => {
    await page.locator('#edit').click(); await page.locator('#title').fill('');
    await page.getByRole('button', { name: 'Save', exact: true }).click();
    assert(await page.locator('#error').isVisible());
    assert.equal((await state()).saveCount, 1);
    assert.equal((await state()).editing, true);
  });
  await check('Cancel can keep editing or discard without saving', async () => {
    await page.locator('#cancel-edit').click();
    assert(await page.locator('#guard').isVisible());
    await page.locator('#keep').click();
    assert.equal(await page.locator('#title').inputValue(), '');
    await page.locator('#cancel-edit').click(); await page.locator('#discard').click();
    assert.equal((await state()).editing, false);
    assert.equal((await state()).saveCount, 1);
  });
  await check('Selection guard and profile isolation', async () => {
    await page.getByRole('button', { name: 'Tablet', exact: true }).click();
    await page.locator('#edit').click(); await page.locator('#title').fill('Draft only for A');
    await page.locator('[data-id="a1"]').click(); await page.locator('#keep').click();
    assert.equal((await state()).selected, 'a2');
    await page.locator('#profile-switch').click(); await page.locator('#discard').click();
    assert.equal((await state()).profile, 'B');
    assert.equal((await state()).draft, null);
    assert.equal(await page.locator('#detail-heading').textContent(), 'Demo B appointment');
    assert.equal(await page.locator('[data-id="a1"]').count(), 0);
    await page.locator('#profile-switch').click();
  });
  await check('Bounded direction changes composition, not record state', async () => {
    await page.locator('#directions [data-direction="bounded"]').click();
    assert.equal(await page.locator('#app').evaluate(e => e.classList.contains('wide')), false);
    await shot('05-tablet-bounded');
    await page.locator('#back').click(); assert(await page.locator('.list-pane').isVisible());
    await page.locator('[data-id="a1"]').click();
  });
  await check('200 percent text and narrow width have no page overflow', async () => {
    await page.locator('#directions [data-direction="context"]').click();
    await page.locator('#text-scale').click();
    await page.locator('#edit').click();
    for (const width of [1440, 390, 320]) {
      await page.setViewportSize({ width, height: 1000 });
      await page.waitForTimeout(100);
      const dimensions = await page.evaluate(() => ({ width: document.documentElement.clientWidth, scroll: document.documentElement.scrollWidth, appWidth: document.querySelector('#app').clientWidth, appScroll: document.querySelector('#app').scrollWidth }));
      assert(dimensions.scroll <= dimensions.width + 1, JSON.stringify(dimensions));
      assert(dimensions.appScroll <= dimensions.appWidth + 1, JSON.stringify(dimensions));
      assert.equal(await page.locator('#app').evaluate(e => e.classList.contains('wide')), false);
    }
    await page.setViewportSize({ width: 390, height: 1000 });
    await shot('06-compact-200-text');
  });
  await check('Keyboard controls, visible focus and minimum targets', async () => {
    await page.locator('#title').focus(); await page.keyboard.press('Tab');
    assert.equal(await page.evaluate(() => document.activeElement.id), 'provider');
    assert.equal(await page.locator('#provider').evaluate(e => getComputedStyle(e).outlineStyle), 'solid');
    await page.keyboard.press('Tab'); assert.equal(await page.evaluate(() => document.activeElement.id), 'date');
    const tooSmall = await page.locator('#app button:visible, #app input:visible').evaluateAll(es => es.filter(e => e.getBoundingClientRect().height < 48 || e.getBoundingClientRect().width < 48).map(e => e.outerHTML));
    assert.deepEqual(tooSmall, []);
  });
  await check('Dark theme and empty fixture', async () => {
    await page.locator('#cancel-edit').click();
    await page.setViewportSize({ width: 1440, height: 1100 });
    await page.locator('#text-scale').click(); await page.locator('#theme').click();
    await shot('07-tablet-dark');
    await page.locator('#empty-toggle').click();
    assert(await page.getByText('No appointments recorded yet', { exact: true }).isVisible());
    assert.equal(await page.locator('[data-id]').count(), 0);
    await shot('08-empty-fixture');
  });
  await check('No script errors or HTTP requests', async () => { assert.deepEqual(errors, []); assert.deepEqual(network, []); });
  const report = { browser: await browser.version(), scope: 'Offline HTML review only; no Flutter, native lifecycle, VoiceOver or device tests', results, count: results.length, errors, network };
  fs.writeFileSync(path.join(__dirname, 'verification.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report, null, 2));
  await browser.close();
})().catch(e => { console.error(e); process.exit(1); });
