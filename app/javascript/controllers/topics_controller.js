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
  }

  toggleSatsLabel(event) {
    const label = event.target;
    if (label.textContent.trim() === 'Sats') {
      label.textContent = '₿';
    } else {
      label.textContent = 'Sats';
    }
  }
}
