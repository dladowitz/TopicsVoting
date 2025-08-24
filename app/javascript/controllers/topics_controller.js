import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="topics"
export default class extends Controller {
  static targets = ["voteForm", "voteCount"]

  connect() {
    console.log("Topics Stimulus controller connected!");
    this.voteFormTargets.forEach(form => {
      form.addEventListener('submit', this.handleVote.bind(this))
    })
    this.subscribeToTopicUpdates();
  }

  async handleVote(event) {
    event.preventDefault();
    const form = event.target;
    console.log("Vote form submitted!", form);
    const url = form.action;
    const method = form.method || 'post';
    const topicListItem = form.closest('.topic-list-item');
    const voteCountSpan = topicListItem.querySelector('.vote-count');
    const upButton = form.closest('.vote-buttons').querySelector('form[action*="upvote"] button');
    const downButton = form.closest('.vote-buttons').querySelector('form[action*="downvote"] button');
    const token = document.querySelector('meta[name="csrf-token"]')?.content;

    const response = await fetch(url, {
      method: method.toUpperCase(),
      headers: {
        'X-CSRF-Token': token,
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: new FormData(form)
    });

    if (response.ok) {
      const data = await response.json();
      if (data.vote_count !== undefined) {
        const prevVotes = parseInt(voteCountSpan.textContent, 10);
        if (prevVotes !== data.vote_count) {
          voteCountSpan.textContent = data.vote_count;
          topicListItem.setAttribute('data-votes', data.vote_count);
          this.animatePop(voteCountSpan);
          this.flashBorder(topicListItem);
        }
        this.resortTopicsInSection(topicListItem);
      }
      if (data.vote_state === 'up') {
        upButton.disabled = true;
        downButton.disabled = false;
      } else if (data.vote_state === 'down') {
        upButton.disabled = false;
        downButton.disabled = true;
      } else {
        upButton.disabled = false;
        downButton.disabled = false;
      }
    }
  }

  resortTopicsInSection(topicListItem) {
    const ul = topicListItem.closest('ul');
    if (!ul) return;
    const items = Array.from(ul.querySelectorAll('.topic-list-item'));
    // Sort by data-votes (descending)
    items.sort((a, b) => parseInt(b.getAttribute('data-votes')) - parseInt(a.getAttribute('data-votes')));
    items.forEach(item => ul.appendChild(item));
  }

  flashBorder(element) {
    element.classList.remove('flash-border');
    void element.offsetWidth;
    element.classList.add('flash-border');
    // Remove border after animation ends
    const removeBorder = () => {
      element.classList.remove('flash-border');
      element.style.border = 'none';
      element.removeEventListener('animationend', removeBorder);
    };
    element.addEventListener('animationend', removeBorder);
  }

  subscribeToTopicUpdates() {
    if (!window.solidCableConsumer) return;
    window.solidCableConsumer.subscriptions.create({ channel: "TopicsChannel" }, {
      received: (data) => {
        const topicListItem = document.querySelector(`.topic-list-item[data-topic-id='${data.id}']`);
        if (topicListItem) {
          // Update votes
          const voteCountSpan = topicListItem.querySelector('.vote-count');
          if (voteCountSpan) {
            const prevVotes = parseInt(voteCountSpan.textContent, 10);
            if (prevVotes !== data.votes) {
              voteCountSpan.textContent = data.votes;
              this.animatePop(voteCountSpan);
              this.flashBorder(topicListItem);
            }
            topicListItem.setAttribute('data-votes', data.votes);
            this.resortTopicsInSection(topicListItem);
          }
          // Update sats
          const satsSpan = topicListItem.querySelector('.sats-received');
          if (satsSpan) {
            const prevSats = parseInt(satsSpan.textContent, 10);
            if (prevSats !== data.sats_received) {
              satsSpan.textContent = data.sats_received;
              this.animateLightning(satsSpan);
              this.flashBorder(topicListItem);
            }
            this.resortTopicsInSection(topicListItem);
          }
        }
      }
    });
  }

  animatePop(element) {
    element.classList.remove('pop');
    // Force reflow to restart animation
    void element.offsetWidth;
    element.classList.add('pop');

    // Remove pop class after animation ends
    const removePop = () => {
      element.classList.remove('pop');
      element.removeEventListener('animationend', removePop);
    };
    element.addEventListener('animationend', removePop);
  }

  animateLightning(element) {
    element.classList.remove('pop');
    element.classList.remove('lightning');
    void element.offsetWidth;
    element.classList.add('lightning');

    // Show page-level canvas lightning effect
    this.showCanvasLightning();
  }

  toggleSatsLabel(event) {
    const label = event.target;
    if (label.textContent.trim() === 'Sats') {
      label.textContent = '₿';
    } else {
      label.textContent = 'Sats';
    }
  }

  showCanvasLightning() {
    // Create canvas element
    const canvas = document.createElement('canvas');
    canvas.className = 'lightning-canvas';
    canvas.id = 'lightning-canvas';
    document.body.appendChild(canvas);

    const context = canvas.getContext('2d');

    // Canvas setup
    let width = 0;
    let height = 0;
    const scale = 1.0;

    // Enable anti-aliasing
    context.imageSmoothingEnabled = true;
    context.imageSmoothingQuality = 'high';

    // Animation variables
    const fps = 45.0;
    let lastFrame = new Date().getTime();
    let flashOpacity = 0.0;

    // Bolt timing
    const boltFlashDuration = 0.25;
    const boltFadeDuration = 0.5;
    const totalBoltDuration = boltFlashDuration + boltFadeDuration;

    // Bolt storage
    const bolts = [];

    // Set canvas size
    const setCanvasSize = () => {
      canvas.setAttribute('width', window.innerWidth);
      canvas.setAttribute('height', window.innerHeight);

      for (let bolt of bolts) {
        bolt.canvas.width = window.innerWidth;
        bolt.canvas.height = window.innerHeight;
      }

      width = Math.ceil(window.innerWidth / scale);
      height = Math.ceil(window.innerHeight / scale);
    };

    // Launch a bolt
    const launchBolt = (x, y, length, direction) => {
      // Set the flash opacity
      flashOpacity = 0.15 + Math.random() * 0.2;

      // Create the bolt canvas
      const boltCanvas = document.createElement('canvas');
      boltCanvas.width = window.innerWidth;
      boltCanvas.height = window.innerHeight;
      const boltContext = boltCanvas.getContext('2d');
      boltContext.scale(scale, scale);

      // Add the bolt to the list
      bolts.push({ canvas: boltCanvas, duration: 0.0 });

      // Launch it
      recursiveLaunchBolt(x, y, length, direction, boltContext);
    };

    // Recursive bolt action
    const recursiveLaunchBolt = (x, y, length, direction, boltContext) => {
      const originalDirection = direction;

      // We draw the bolt incrementally to get a nice animated effect
      const boltInterval = setInterval(() => {
        if (length <= 0) {
          clearInterval(boltInterval);
          return;
        }

        let i = 0;
        while (i++ < Math.floor(45 / scale) && length > 0) {
          const x1 = x;
          const y1 = y;
          x += Math.cos(direction);
          y -= Math.sin(direction);
          length--;

          const alpha = Math.min(1.0, length / 350.0);
          boltContext.strokeStyle = `rgba(247, 147, 26, ${alpha})`;
          boltContext.lineWidth = 1.5;
          boltContext.lineCap = 'round';
          boltContext.lineJoin = 'round';
          boltContext.beginPath();
          boltContext.moveTo(x1, y1);
          boltContext.lineTo(x, y);
          boltContext.stroke();

          direction = originalDirection + (-Math.PI / 8.0 + Math.random() * (Math.PI / 4.0));

          if (Math.random() > 0.98) {
            recursiveLaunchBolt(x1, y1, length * (0.3 + Math.random() * 0.4), originalDirection + (-Math.PI / 6.0 + Math.random() * (Math.PI / 3.0)), boltContext);
          } else if (Math.random() > 0.95) {
            recursiveLaunchBolt(x1, y1, length, originalDirection + (-Math.PI / 6.0 + Math.random() * (Math.PI / 3.0)), boltContext);
            length = 0;
          }
        }
      }, 10);
    };

    // Animation tick
    const tick = () => {
      // Keep track of the frame time
      const frame = new Date().getTime();
      const elapsed = (frame - lastFrame) / 1000.0;
      lastFrame = frame;

      // Clear the canvas
      context.clearRect(0.0, 0.0, window.innerWidth, window.innerHeight);

      // Draw the flash
      if (flashOpacity > 0.0) {
        context.fillStyle = `rgba(247, 147, 26, ${flashOpacity})`;
        context.fillRect(0.0, 0.0, window.innerWidth, window.innerHeight);
        flashOpacity = Math.max(0.0, flashOpacity - 2.0 * elapsed);
      }

      // Draw each bolt
      for (let i = 0; i < bolts.length; i++) {
        const bolt = bolts[i];
        bolt.duration += elapsed;

        if (bolt.duration >= totalBoltDuration) {
          bolts.splice(i, 1);
          i--;
          continue;
        }

        context.globalAlpha = Math.max(0.0, Math.min(1.0, (totalBoltDuration - bolt.duration) / boltFadeDuration));
        context.drawImage(bolt.canvas, 0.0, 0.0);
      }
    };

    // Initialize
    setCanvasSize();
    canvas.classList.add('active');

    // Show notification
    this.showLightningNotification();

    // Launch initial bolts
    setTimeout(() => {
      // Launch multiple bolts from the top of the screen
      for (let i = 0; i < 3; i++) {
        setTimeout(() => {
          const x = Math.floor(Math.random() * width);
          const y = 0; // Start from the very top
          const length = Math.floor(height * 0.8 + Math.random() * (height * 0.2));
          launchBolt(x, y, length, Math.PI * 3.0 / 2.0);
        }, i * 200);
      }
    }, 100);

    // Start animation loop
    const animationInterval = setInterval(tick, 1000.0 / fps);

    // Clean up after animation
    setTimeout(() => {
      clearInterval(animationInterval);
      canvas.classList.remove('active');
      setTimeout(() => {
        if (canvas.parentNode) {
          canvas.parentNode.removeChild(canvas);
        }
      }, 300);
    }, 3000);
  }

  showLightningNotification() {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'lightning-notification';
    notification.textContent = 'Lightning Payment Received';

    // Add to page
    document.body.appendChild(notification);

    // Remove after animation completes
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 3000);
  }
}
