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
});
