export const hasAttr = (el, attr) =>
    typeof el === "object" && el !== null && "getAttribute" in el && el.hasAttribute(attr);