import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

const REFRESH_MS = 60 * 1000;

export default class HacfPresencePill extends Component {
  @service currentUser;
  @service siteSettings;

  @tracked data = null;
  @tracked open = false;
  timer = null;

  constructor() {
    super(...arguments);
    this.load();
    this.timer = setInterval(() => this.load(), REFRESH_MS);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearInterval(this.timer);
  }

  async load() {
    if (document.hidden) {
      return;
    }
    try {
      this.data = await ajax("/hacf-presence");
    } catch {
      // silencieux : on garde la dernière valeur
    }
  }

  get visible() {
    return this.siteSettings.hacf_presence_enabled && this.data;
  }

  get users() {
    return (this.data?.users || []).map((u) => ({
      username: u.username,
      url: `/u/${u.username}`,
      avatar: (u.avatar_template || "").replace("{size}", "48"),
    }));
  }

  get stack() {
    return this.users.slice(0, 5);
  }

  get extra() {
    return Math.max(0, this.users.length - 5);
  }

  get visitors() {
    return typeof this.data?.visitors === "number" ? this.data.visitors : null;
  }

  get members() {
    return this.data?.count ?? this.users.length;
  }

  @action
  toggle() {
    this.open = !this.open;
  }

  <template>
    {{#if this.visible}}
      <div class="hacf-presence">
        <button
          type="button"
          class="hacf-presence__pill"
          {{on "click" this.toggle}}
          aria-expanded={{if this.open "true" "false"}}
        >
          <span class="hacf-presence__dot"></span>
          {{#if this.visitors}}
            <span>{{this.visitors}} visiteurs</span>
            <span class="hacf-presence__sep">·</span>
          {{/if}}
          <span>{{this.members}} membres</span>
          <span class="hacf-presence__stack">
            {{#each this.stack as |u|}}
              <img src={{u.avatar}} alt={{u.username}} class="hacf-presence__avatar" />
            {{/each}}
            {{#if this.extra}}
              <span class="hacf-presence__more">+{{this.extra}}</span>
            {{/if}}
          </span>
        </button>
        {{#if this.open}}
          <div class="hacf-presence__panel">
            {{#each this.users as |u|}}
              <a href={{u.url}} class="hacf-presence__row">
                <img src={{u.avatar}} alt="" class="hacf-presence__avatar" />
                <span>{{u.username}}</span>
              </a>
            {{else}}
              <span class="hacf-presence__empty">Personne pour le moment</span>
            {{/each}}
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
