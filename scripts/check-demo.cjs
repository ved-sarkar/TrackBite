const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const path = require('node:path');
const html = fs.readFileSync(path.join(__dirname, '../demo/TrackBite-Demo.html'), 'utf8');
const nodes = {};
const listeners = {};
const document = {
  getElementById: id => nodes[id] ??= {setAttribute(k, v) { this[k] = v; }},
  addEventListener: (event, fn) => { listeners[event] = fn; }
};
const context = {document, console};
vm.createContext(context);
vm.runInContext(html.match(/<script>([\s\S]*?)<\/script>/)[1], context);
function run(code) { return vm.runInContext(code, context); }
run("selectState('empty')");
assert.equal(nodes.weight.textContent, 100);
assert.equal(nodes.gross.textContent, '100 g');
assert.equal(nodes.net.textContent, '0 g');
assert.equal(nodes.identify.disabled, true);
run("selectState('food')");
assert.equal(nodes.weight.textContent, 40);
assert.equal(nodes.gross.textContent, '140 g');
assert.equal(nodes.net.textContent, '40 g');
assert.equal(nodes.identify.disabled, false);
nodes.identify.onclick();
assert.equal(nodes.reviewPanel.hidden, false);
assert.equal(nodes.reviewContent.hidden, false);
nodes.ingredientName.value='';
nodes.save.onclick();
assert.equal(nodes.logContent.hidden, true);
nodes.ingredientName.value='Example food';
nodes.save.onclick();
assert.match(nodes.notice.textContent, /40 g · 20 kcal/);
assert.equal(nodes.save.disabled, true);
assert.equal(nodes.logContent.hidden, false);
assert.equal(nodes.loggedName.textContent, 'Example food');
nodes.navReview.onclick();
assert.equal(nodes.reviewPanel.hidden, false);
run("selectState('empty')");
assert.equal(nodes.reviewContent.hidden, true);
assert.equal(nodes.logContent.hidden, true);
assert.equal(nodes.notice.textContent, '');
for (const input of ['{gross:90,tare:100}', '{gross:NaN,tare:0}', '{gross:Infinity,tare:0}', '{gross:100,tare:-1}']) {
  assert.throws(() => run('netReading(' + input + ')'));
}
listeners.keydown({key:'2'});
assert.equal(nodes.weight.textContent, 40);
listeners.keydown({key:'1'});
assert.equal(nodes.weight.textContent, 100);
listeners.keydown({key:'2',target:{tagName:'INPUT'}});
assert.equal(nodes.weight.textContent, 100);
assert.match(html, /connect-src 'none'/);
assert.doesNotMatch(html, /getUserMedia|fetch\(|XMLHttpRequest|https?:\/\//);
console.log('PASS: empty plate 100 gross / 100 tare / 0 net');
console.log('PASS: food 140 gross / 100 tare / 40 net');
console.log('PASS: ingredient review, required name, confirmed 20 kcal log, navigation and reset');
console.log('PASS: invalid readings rejected, keyboard states and offline restrictions');
