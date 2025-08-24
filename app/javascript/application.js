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

// Function to initialize the sats/BTC toggle
function initializeSatsBtcToggle() {
  const sliders = document.querySelectorAll('#satsBtcToggleSlider');

  // If no sliders found, just update labels with current mode
  if (sliders.length === 0) {
    const satsMode = localStorage.getItem('satsMode') || 'sats';
    updateSatsLabels(satsMode);
    return;
  }

  sliders.forEach(function(slider) {
    // Remove existing event listeners to prevent duplicates
    const newSlider = slider.cloneNode(true);
    slider.parentNode.replaceChild(newSlider, slider);

    // Set initial state from localStorage, or random on first visit
    let satsMode = localStorage.getItem('satsMode');
    if (!satsMode) {
      satsMode = Math.random() < 0.5 ? 'sats' : 'btc';
      localStorage.setItem('satsMode', satsMode);
    }
    newSlider.checked = satsMode === 'btc';
    updateSatsLabels(satsMode);
    newSlider.addEventListener('change', function() {
      satsMode = newSlider.checked ? 'btc' : 'sats';
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
  });
}

// Initialize on DOM content loaded (for initial page load)
document.addEventListener('DOMContentLoaded', initializeSatsBtcToggle);

// Initialize on Turbo navigation (for subsequent page loads)
document.addEventListener('turbo:load', initializeSatsBtcToggle);
document.addEventListener('turbo:render', initializeSatsBtcToggle);
document.addEventListener('turbo:frame-load', initializeSatsBtcToggle);

function updateSatsLabels(mode) {
  document.querySelectorAll('.sats-label').forEach(function(el) {
    el.textContent = mode === 'sats' ? 'Received: Sats' : 'Received: ₿';
  });
  document.querySelectorAll('.sats-symbol').forEach(function(el) {
    el.innerHTML = mode === 'sats' ? '<i class="fak fa-satoshisymbol-solid"></i>' : '₿';
  });
  document.querySelectorAll('.sats-received').forEach(function(el) {
    el.textContent = el.dataset.sats;
  });

  // Update amount-unit elements for payout page
  document.querySelectorAll('.amount-unit').forEach(function(el) {
    el.textContent = mode === 'sats' ? 'sats' : '₿';
  });

  // Update topic-payments elements for payout page
  document.querySelectorAll('.topic-payments .sats-received').forEach(function(el) {
    const satsValue = el.dataset.sats;
    el.textContent = satsValue;
    // Update the "sats" text that follows
    const satsText = el.nextSibling;
    if (satsText && satsText.textContent.trim() === 'sats') {
      satsText.textContent = mode === 'sats' ? 'sats' : '₿';
    }
  });
}
