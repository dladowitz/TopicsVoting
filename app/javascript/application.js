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

document.addEventListener('DOMContentLoaded', function() {
  const slider = document.getElementById('satsBtcToggleSlider');
  if (slider) {
    // Set initial state from localStorage
    let satsMode = localStorage.getItem('satsMode') || 'sats';
    slider.checked = satsMode === 'btc';
    updateSatsLabels(satsMode);
    slider.addEventListener('change', function() {
      satsMode = slider.checked ? 'btc' : 'sats';
      localStorage.setItem('satsMode', satsMode);
      updateSatsLabels(satsMode);
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
