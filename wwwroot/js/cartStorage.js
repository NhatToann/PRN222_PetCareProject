// cartStorage.js — React-parity localStorage helpers for product cart persistence.
// Mirrors `localStorage.cart` from React frontend/src/pages/CartPage.jsx.

window.cartStorage = (function () {
  const KEY = 'cart';
  const EVENT = 'cartUpdated';

  function read() {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return [];
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  function write(items) {
    if (!Array.isArray(items)) {
      localStorage.removeItem(KEY);
    } else {
      localStorage.setItem(KEY, JSON.stringify(items));
    }
    window.dispatchEvent(new Event(EVENT));
    return items;
  }

  function clear() {
    write([]);
  }

  function onChange(handler) {
    function listener() { handler(read()); }
    window.addEventListener(EVENT, listener);
    window.addEventListener('storage', listener);
    return function () {
      window.removeEventListener(EVENT, listener);
      window.removeEventListener('storage', listener);
    };
  }

  return { read, write, clear, onChange };
})();
