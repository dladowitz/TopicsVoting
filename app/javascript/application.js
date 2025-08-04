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
    // Set initial state from localStorage, or random on first visit
    let satsMode = localStorage.getItem('satsMode');
    if (!satsMode) {
      satsMode = Math.random() < 0.5 ? 'sats' : 'btc';
      localStorage.setItem('satsMode', satsMode);
    }
    slider.checked = satsMode === 'btc';
    updateSatsLabels(satsMode);
    slider.addEventListener('change', function() {
      satsMode = slider.checked ? 'btc' : 'sats';
      localStorage.setItem('satsMode', satsMode);
      updateSatsLabels(satsMode);
      // Track toggle preference
      fetch('/toggles/increment', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ name: satsMode === 'btc' ? 'btc_preference' : 'sats_preference' })
      });
    });
  }
});

function updateSatsLabels(mode) {
  document.querySelectorAll('.sats-label').forEach(function(el) {
    el.textContent = mode === 'sats' ? 'Sats:' : '₿';
  });
  document.querySelectorAll('.sats-symbol').forEach(function(el) {
    el.innerHTML = mode === 'sats' ? '<i class="fak fa-satoshisymbol-solid"></i>' : '₿';
  });
  document.querySelectorAll('.sats-received').forEach(function(el) {
    el.textContent = el.dataset.sats;
  });
}
