import { Controller } from "@hotwired/stimulus";

const buildUrlWithQuery = (baseUrl, queryObj = {}) => {
  const queryParams = new URLSearchParams(queryObj);
  if (queryParams.toString().length === 0) return baseUrl;

  return `${baseUrl}?${queryParams.toString()}`;
};

export default class extends Controller {
  static values = {
    debounceTimeout: { type: Number, default: 300 },
    previewFrameId: String,
    searchPath: String,
    searchParamName: { type: String, default: "q" },
  };

  initialize() {
    this.previewFrame = document.getElementById(this.previewFrameIdValue);
    this.onFrameUpdate = this.onFrameUpdate.bind(this);
  }

  connect() {
    this.previewFrame.addEventListener("turbo:frame-load", this.onFrameUpdate);
  }

  disconnect() {
    this.previewFrame.removeEventListener(
      "turbo:frame-load",
      this.onFrameUpdate,
    );
  }

  get query() {
    return this.element.value;
  }

  get searchUrl() {
    return buildUrlWithQuery(this.searchPathValue, {
      [this.searchParamNameValue]: this.query,
    });
  }

  search() {
    if (this.timer) clearTimeout(this.timer);

    this.timer = setTimeout(() => {
      this.updateFrame();
    }, this.debounceTimeoutValue);
  }

  updateFrame() {
    if (this.query.length >= 3) {
      this.reloadFrame();
    } else {
      this.resetFrame();
    }
  }

  reloadFrame() {
    this.previewFrame.src = this.searchUrl;
    this.previewFrame.reload();
  }

  resetFrame() {
    this.previewFrame.src = "";
    this.previewFrame.innerHTML = "";
  }

  onFrameUpdate() {
    if (this.navigationalElements) {
      this.navigationalElements.forEach((el) =>
        el.removeEventListener("turbo:click", this.resetFrame),
      );
    }
    this.navigationalElements = this.previewFrame.querySelectorAll("a");
    this.navigationalElements.forEach((link) =>
      link.addEventListener("turbo:click", this.resetFrame),
    );
  }
}
