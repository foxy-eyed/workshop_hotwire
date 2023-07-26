// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import morphdom from "morphdom";

import { hasAttr } from "./utils";

let prevPath = window.location.pathname;

document.addEventListener("turbo:before-render", (event) => {
  Turbo.navigator.currentVisit.scrolled = prevPath === window.location.pathname;
  prevPath = window.location.pathname;

  event.detail.render = async (prevEl, newEl) => {
    await new Promise((resolve) => setTimeout(() => resolve(), 0));

    morphdom(prevEl, newEl, {
      onBeforeElUpdated: (fromEl, toEl) => {
        return (
          !fromEl.isEqualNode(toEl) &&
          !hasAttr(fromEl, "data-morphdom-permanent")
        );
      },
      onElUpdated: (el) => {
        if (hasAttr(el, "data-morphdom-permanent")) {
          console.error("permanent element updated");
        }
      },
    });
  };

  if (document.startViewTransition) {
    event.preventDefault();

    document.startViewTransition(() => {
      event.detail.resume();
    });
  }
});

document.addEventListener("turbo:before-frame-render", (event) => {
  event.detail.render = (currentElement, newElement) => {
    if (
      currentElement.hasAttribute("transition-name") &&
      newElement.hasAttribute("transition-name") &&
      currentElement.firstElementChild?.getAttribute("transition-id") !==
        newElement.firstElementChild?.getAttribute("transition-id")
    ) {
      document.documentElement.setAttribute(
        "transition",
        currentElement.getAttribute("transition-name")
      );
    }

    morphdom(currentElement, newElement, {
      childrenOnly: true,
    });
  };

  if (document.startViewTransition) {
    event.preventDefault();

    document
      .startViewTransition(() => {
        event.detail.resume();
      })
      .finished.then(() => {
        document.documentElement.removeAttribute("transition");
      });
  }
});
