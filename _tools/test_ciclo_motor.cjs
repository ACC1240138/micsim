// Run with: node _tools/test_ciclo_motor.cjs
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.resolve(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'ciclo_motor_animado.html'), 'utf8');
assert.equal(html, fs.readFileSync(path.join(root, '__andres_control/figures_paper_outline/ciclo_motor_animado.html'), 'utf8'));
const source = html.match(/<script>([\s\S]*?)<\/script>/)[1];
const element = { textContent: '', style: {}, classList: { add() {}, remove() {} },
  addEventListener() {}, getBoundingClientRect() { return {}; } };
const context = vm.createContext({ console,
  window: { matchMedia: () => ({ matches: true }) },
  document: { querySelector: () => element, addEventListener() {} } });
vm.runInContext(source.replace('build(); reset(seed);', ''), context);
const renderRoll = context.roll;
// Exercise the actual cycle without animation delays or a browser DOM.
vm.runInContext(`
  paintAll = setStation = placeRunner = renderYear = syncButtons = prep = updateTally = runner = function () {};
  read = tell = all = roll = function () { return Promise.resolve(); };
  dots = Array.from({length:N}, function () { return {last:'', g:document.querySelector('')}; });
`, context);

async function run(scenario, seed, identical = false) {
  context.scen = scenario;
  const original = context.SC[scenario];
  if (identical) context.SC[scenario] = context.S0;
  context.reset(seed);
  context.slots[0].age = 64;
  const qDeath = context.qDeath;
  context.qDeath = age => age >= 64 ? 0 : qDeath(age);
  let cycles = 0;
  while (context.year <= context.END) {
    if (context.stepIdx === 0) cycles++;
    await context.RUN[context.stepIdx]();
    assert(context.slots.every(p => p.age <= 73));
    if (context.stepIdx === 10) {
      for (const p of context.slots.filter(p => p.alive)) {
        for (const b of [p.s0, p.sc]) {
          if (context.drinker(b.state)) assert.equal(b.state, context.stateFromG(p.sex, b.g));
        }
      }
    }
    context.advance();
  }
  context.qDeath = qDeath;
  context.SC[scenario] = original;
  assert.equal(cycles, 10);
  assert.equal(context.slots[0].age, 73);
  for (const value of Object.values(context.acc)) assert(Number.isFinite(value));
  if (identical) {
    assert.equal(context.acc.newBi, 0);
    assert.equal(context.acc.deaths, 0);
    assert.equal(context.acc.yll, 0);
  }
  return JSON.stringify(context.acc);
}

(async () => {
  const pips = Array.from({ length: 9 }, () => ({ className: '' }));
  const nodes = new Map();
  const select = context.$;
  context.$ = selector => {
    if (!nodes.has(selector)) nodes.set(selector, { style: {}, querySelectorAll: () => pips });
    return nodes.get(selector);
  };
  const read = context.read;
  const sleep = context.sleep;
  context.read = () => Promise.resolve();
  context.sleep = () => Promise.resolve();
  for (let face = 1; face <= 6; face++) {
    await renderRoll((face - 0.5) / 6, 0.5, '', '', '');
    assert.equal(pips.filter(p => p.className === 'on').length, face);
    assert.equal(nodes.get('#die').className, 'die');
  }
  assert.match(html, /class="draw-label">U<\/span>/);
  assert.match(html, /id="reseed">Nueva réplica/);
  context.$ = select;
  context.read = read;
  context.sleep = sleep;
  for (const sex of ['M', 'H']) {
    for (const state of ['C1', 'C2', 'C3']) {
      for (const u of [0, 0.001, 0.5, 0.999999]) {
        assert.equal(context.stateFromG(sex, context.drawG(sex, state, u)), state);
      }
    }
    assert.equal(context.stateFromG(sex, context.CUT[sex][0]), 'C1');
    assert.equal(context.stateFromG(sex, context.CUT[sex][1]), 'C2');
  }
  for (const scenario of ['S1', 'S2', 'S3']) {
    for (const seed of [20251, 20252, 20253]) await run(scenario, seed);
  }
  assert.equal(await run('S3', 20251), await run('S3', 20251));
  await run('S3', 20251, true);
  console.log('PASS: six die faces and U label, category boundaries, 10-year horizon, three scenarios, reproducibility, identical-policy null effect, synchronized copies.');
})().catch(error => { console.error(error); process.exitCode = 1; });
