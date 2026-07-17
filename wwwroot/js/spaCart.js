// spaCart.js — React-parity localStorage helpers for Service Booking port.
// Mirrors `localStorage.spaCart` from React frontend/src/pages/SpaCartPage.jsx.

window.spaCart = (function () {
  const KEY = 'spaCart';
  const EVENT = 'spaCartUpdated';

  function read() {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return [];
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed.filter((n) => Number.isFinite(Number(n))).map((n) => Number(n)) : [];
    } catch {
      return [];
    }
  }

  function write(ids) {
    const next = Array.isArray(ids) ? Array.from(new Set(ids.map(Number).filter((n) => Number.isFinite(n) && n > 0))) : [];
    localStorage.setItem(KEY, JSON.stringify(next));
    window.dispatchEvent(new Event(EVENT));
    return next;
  }

  function add(id) {
    const current = read();
    if (current.includes(Number(id))) return current;
    return write([...current, Number(id)]);
  }

  function remove(id) {
    const next = read().filter((n) => n !== Number(id));
    write(next);
    return next;
  }

  function clear() {
    write([]);
  }

  function count() {
    return read().length;
  }

  function onChange(handler) {
    function listener() { handler(read()); }
    window.addEventListener(EVENT, listener);
    window.addEventListener('storage', listener);
    return () => {
      window.removeEventListener(EVENT, listener);
      window.removeEventListener('storage', listener);
    };
  }

  return { read, write, add, remove, clear, count, onChange };
})();