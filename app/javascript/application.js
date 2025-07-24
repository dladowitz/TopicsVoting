// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { createConsumer } from "@rails/actioncable"
window.solidCableConsumer = createConsumer()
import "channels"
document.addEventListener('visibilitychange', function() {
  if (document.visibilityState === 'visible') {
    // Save scroll position before reload
    localStorage.setItem('scrollY', window.scrollY);
    window.location.reload();
  }
});

window.addEventListener('DOMContentLoaded', function() {
  const scrollY = localStorage.getItem('scrollY');
  if (scrollY !== null) {
    window.scrollTo(0, parseInt(scrollY, 10));
    localStorage.removeItem('scrollY');
  }
  const toggle = document.getElementById('satsBtcToggle');
  if (toggle) {
    // Set initial state from localStorage
    let satsMode = localStorage.getItem('satsMode') || 'sats';
    updateSatsLabels(satsMode);
    toggle.textContent = satsMode === 'sats' ? 'Show as BTC' : 'Show in Sats';
    toggle.addEventListener('click', function() {
      satsMode = satsMode === 'sats' ? 'btc' : 'sats';
      localStorage.setItem('satsMode', satsMode);
      updateSatsLabels(satsMode);
      toggle.textContent = satsMode === 'sats' ? 'Show as BTC' : 'Show in Sats';
    });
  }
});

function updateSatsLabels(mode) {
  document.querySelectorAll('.sats-label').forEach(function(el) {
    el.textContent = mode === 'sats' ? 'Sats:' : 'BTC:';
  });
  document.querySelectorAll('.sats-symbol').forEach(function(el) {
    el.innerHTML = mode === 'sats' ? '<i class="fak fa-satoshisymbol-solid"></i>' : '₿';
  });
  document.querySelectorAll('.sats-received').forEach(function(el) {
    el.textContent = el.dataset.sats;
  });
}
