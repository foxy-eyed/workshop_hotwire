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
  }

  get query() {
    return this.element.value;
  }

  get searchUrl() {
    if (this.query.length < 3) return "";

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
    this.previewFrame.src = this.searchUrl;
    this.previewFrame.reload();
  }
}
