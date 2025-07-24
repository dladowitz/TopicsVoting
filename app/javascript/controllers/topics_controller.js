import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="topics"
export default class extends Controller {
  static targets = ["voteForm", "voteCount"]

  connect() {
    console.log("Topics Stimulus controller connected!");
    this.voteFormTargets.forEach(form => {
      form.addEventListener('submit', this.handleVote.bind(this))
    })
  }

  async handleVote(event) {
    event.preventDefault();
    const form = event.target;
    console.log("Vote form submitted!", form);
    const url = form.action;
    const method = form.method || 'post';
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    const topicListItem = form.closest('.topic-list-item');
    const voteCountSpan = topicListItem.querySelector('.vote-count');
    const upButton = form.closest('.vote-buttons').querySelector('form[action*="upvote"] button');
    const downButton = form.closest('.vote-buttons').querySelector('form[action*="downvote"] button');

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
        voteCountSpan.textContent = data.vote_count;
        topicListItem.setAttribute('data-votes', data.vote_count);
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
    // Find the parent <ul> (the section's topic list)
    const ul = topicListItem.closest('ul');
    if (!ul) return;
    // Get all topic-list-item <li>s in this section
    const items = Array.from(ul.querySelectorAll('.topic-list-item'));
    // Sort by data-votes (descending)
    items.sort((a, b) => parseInt(b.getAttribute('data-votes')) - parseInt(a.getAttribute('data-votes')));
    // Re-append in sorted order
    items.forEach(item => ul.appendChild(item));
  }
} 