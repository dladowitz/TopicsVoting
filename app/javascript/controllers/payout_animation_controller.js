import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["successMessage", "payoutAmount", "processButton", "lightningElement"]

  connect() {
    // Check if there's a success message and trigger animation
    if (this.hasSuccessMessageTarget) {
      this.triggerSuccessAnimation()
    }

    // Add click animation to process button
    if (this.hasProcessButtonTarget) {
      this.addButtonAnimation()
    }

    // Setup lightning effects toggle
    this.setupLightningEffectsToggle()
  }

  showCanvasLightning() {
    // Check which lightning effect to use
    if (this.isSingleLightningEnabled()) {
      this.showSingleLightning()
    } else {
      this.showMultipleLightning()
    }
  }

  showSingleLightning() {
    // Create canvas element
    const canvas = document.createElement('canvas');
    canvas.className = 'lightning-canvas';
    canvas.id = 'payout-single-lightning-canvas';
    document.body.appendChild(canvas);

    const context = canvas.getContext('2d');

    // Set canvas size
    const height = document.body.offsetHeight;
    const width = document.body.offsetWidth;
    canvas.setAttribute("height", height);
    canvas.setAttribute("width", width);

    // Lightning parameters
    const lightningStrikeOffset = 5;
    const lightningStrikeLength = 100;
    const lightningBoltLength = 5;
    const lightningThickness = 4;
    const canvasHeight = canvas.height;
    const canvasWidth = canvas.width;

    // Utility functions
    const createVector = function(x, y) { return { x, y } }

    const getRandomFloat = function(min, max) {
      const random = Math.random() * (max - min + 1) + min;
      return random;
    }

    const getRandomInteger = function(min, max) {
      return Math.floor(getRandomFloat(min, max));
    }

    const clearCanvas = function(x, y, height, width) {
      rectX = x || 0;
      rectY = y || 0;
      rectHeight = height || canvasHeight;
      rectWidth = width || canvasWidth;
      context.clearRect(rectX, rectY, rectWidth, rectHeight);
      context.beginPath();
    }

    const line = function(start, end, thickness, opacity) {
      context.beginPath();
      context.moveTo(start.x, start.y);
      context.lineTo(end.x, end.y);
      context.lineWidth = thickness;
      context.strokeStyle = `rgba(247, 147, 26, ${opacity})`; // Use orange color
      context.shadowBlur = 30;
      context.shadowColor = "#f7931a"; // Orange shadow
      context.stroke();
      context.closePath();
    }

    class Lightning {
      constructor(x1, y1, x2, y2, thickness, opacity) {
        this.start = createVector(x1, y1);
        this.end = createVector(x2, y2);
        this.thickness = thickness;
        this.opacity = opacity;
      }
      draw() {
        return line(this.start, this.end, this.thickness, this.opacity);
      }
    }

    let lightning = [];

    const createLightning = function() {
      lightning = [];
      let lightningX1 = getRandomInteger(2, canvasWidth - 2);
      let lightningX2 = getRandomInteger(lightningX1 - lightningStrikeOffset, lightningX1 + lightningStrikeOffset);
      lightning[0] = new Lightning(lightningX1, 0, lightningX2, lightningBoltLength, lightningThickness, 1);
      for (let l = 1; l < lightningStrikeLength; l++) {
        let lastBolt = lightning[l - 1];
        let lx1 = lastBolt.end.x;
        let lx2 = getRandomInteger(lx1 - lightningStrikeOffset, lx1 + lightningStrikeOffset);
        lightning.push(new Lightning(
          lx1,
          lastBolt.end.y,
          lx2,
          lastBolt.end.y + lightningBoltLength,
          lastBolt.thickness,
          lastBolt.opacity
        ));
      }
    }

    const setup = function() {
      createLightning();
      for (let i = 0 ; i < lightning.length ; i++) {
        lightning[i].draw();
      }
    }

    const animate = function() {
      clearCanvas();

      for (let i = 0 ; i < lightning.length ; i++) {
        lightning[i].opacity -= 0.01;
        lightning[i].thickness -= 0.05;
        if (lightning[i].thickness <= 2) {
          lightning[i].end.y -= 0.05;
        }
        lightning[i].draw();
      }

      requestAnimationFrame(animate);
    }

    // Initialize
    canvas.classList.add('active');
    setup();
    requestAnimationFrame(animate);

    // Clean up after animation
    setTimeout(() => {
      canvas.classList.remove('active');
      setTimeout(() => {
        if (canvas.parentNode) {
          canvas.parentNode.removeChild(canvas);
        }
      }, 300);
    }, 3000);
  }

  showMultipleLightning() {
    // Create canvas element
    const canvas = document.createElement('canvas');
    canvas.className = 'lightning-canvas';
    canvas.id = 'payout-lightning-canvas';
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

    // Launch initial bolts from multiple directions
    setTimeout(() => {
      // Launch bolts from the top of the screen
      for (let i = 0; i < 5; i++) {
        setTimeout(() => {
          const x = Math.floor(Math.random() * width);
          const y = 0; // Start from the very top
          const length = Math.floor(height * 0.8 + Math.random() * (height * 0.2));
          launchBolt(x, y, length, Math.PI * 3.0 / 2.0);
        }, i * 150);
      }

      // Launch bolts from the sides
      setTimeout(() => {
        for (let i = 0; i < 3; i++) {
          setTimeout(() => {
            const x = Math.random() > 0.5 ? 0 : width; // Left or right side
            const y = Math.floor(Math.random() * height);
            const length = Math.floor(Math.max(width, height) * 0.6);
            const direction = x === 0 ? 0 : Math.PI; // Right or left
            launchBolt(x, y, length, direction);
          }, i * 200);
        }
      }, 500);
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
    }, 4000);
  }

  showPayoutNotification() {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'payout-notification';
    notification.textContent = 'Lightning Payout Successful! ⚡';

    // Add to page
    document.body.appendChild(notification);

    // Remove after animation completes
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 4000);
  }

  triggerSuccessAnimation() {
    const message = this.successMessageTarget

    // Add a slight delay to ensure the message is visible
    setTimeout(() => {
      message.classList.add("payout-success-animation")

      // Show dramatic canvas lightning effect
      this.showCanvasLightning()

      // Show payout notification
      this.showPayoutNotification()

      // Add screen flash effect
      this.showScreenFlash()

      // Add lightning effect to payout amounts
      this.animatePayoutAmounts()

      // Add lightning effect to lightning elements if they exist
      this.triggerLightningEffect()

      // Remove animation class after animation completes
      setTimeout(() => {
        message.classList.remove("payout-success-animation")
      }, 4000)
    }, 100)
  }

  showScreenFlash() {
    // Create screen flash element
    const flash = document.createElement('div');
    flash.className = 'payout-screen-flash';
    document.body.appendChild(flash);

    // Add vibration effect to simulate sound
    this.addVibrationEffect();

    // Remove after animation completes
    setTimeout(() => {
      if (flash.parentNode) {
        flash.parentNode.removeChild(flash);
      }
    }, 1000);
  }

  addVibrationEffect() {
    // Add a subtle vibration effect to the page
    const body = document.body;
    const originalTransform = body.style.transform;

    // Create vibration animation
    let vibrationCount = 0;
    const maxVibrations = 6;
    const vibrationInterval = setInterval(() => {
      if (vibrationCount >= maxVibrations) {
        clearInterval(vibrationInterval);
        body.style.transform = originalTransform;
        return;
      }

      const intensity = (maxVibrations - vibrationCount) * 0.5;
      const x = (Math.random() - 0.5) * intensity;
      const y = (Math.random() - 0.5) * intensity;
      body.style.transform = `translate(${x}px, ${y}px)`;

      vibrationCount++;
    }, 50);
  }

  animatePayoutAmounts() {
    if (this.hasPayoutAmountTarget) {
      this.payoutAmountTargets.forEach(amount => {
        amount.classList.add("payout-amount-updated")

        // Remove animation class after animation completes
        setTimeout(() => {
          amount.classList.remove("payout-amount-updated")
        }, 1000)
      })
    }
  }

  addButtonAnimation() {
    this.processButtonTarget.addEventListener("click", (e) => {
      // Add a subtle pulse effect when button is clicked
      this.processButtonTarget.style.transform = "scale(0.95)"

      setTimeout(() => {
        this.processButtonTarget.style.transform = "scale(1)"
      }, 150)
    })
  }

  triggerLightningEffect() {
    if (this.hasLightningElementTarget) {
      this.lightningElementTargets.forEach(element => {
        element.classList.add("payout-lightning-effect")

        // Remove animation class after animation completes
        setTimeout(() => {
          element.classList.remove("payout-lightning-effect")
        }, 700)
      })
    }
  }

  setupLightningEffectsToggle() {
    const toggle = document.getElementById('lightningEffectsToggleSlider');
    if (toggle) {
      toggle.addEventListener('change', (event) => {
        // Store the preference in localStorage (checked = single lightning, unchecked = multiple lightning)
        localStorage.setItem('payoutLightningEffect', event.target.checked ? 'single' : 'multiple');
      });

      // Load saved preference
      const savedPreference = localStorage.getItem('payoutLightningEffect');
      if (savedPreference !== null) {
        toggle.checked = savedPreference === 'single';
      } else {
        // Default to multiple lightning (unchecked)
        toggle.checked = false;
      }
    }
  }

  isSingleLightningEnabled() {
    const toggle = document.getElementById('lightningEffectsToggleSlider');
    return toggle ? toggle.checked : false; // checked = single lightning
  }

  // Method to trigger animation programmatically (for future use)
  triggerPayoutSuccess() {
    this.triggerSuccessAnimation()
  }
}
