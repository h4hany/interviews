# HTML & HTML5:

## 1- What are semantic tags ?! Why we need them ?!

**Semantic tags** are HTML elements that clearly describe their meaning and content both to the browser and to
developers. These tags define the structure and purpose of the content inside them, making the code more readable and
improving accessibility and search engine optimization (SEO).

### Why Do We Need Semantic Tags?

1. **Improved Readability**:
    - Make the structure of the webpage more understandable to developers.
2. **SEO (Search Engine Optimization)**:
    - Search engines use the structure of the HTML page to understand its content. Semantic tags help search engines
      like Google understand what parts of the page are the most important, boosting search rankings for relevant
      content.
3. **Accessibility**:
    - Screen readers and other assistive technologies rely on semantic tags to navigate and interpret the content more
      accurately. For example, a screen reader will treat a `<nav>` tag as navigation and allow users to quickly skip to
      the main content.
4. **Better for Browsers**:
    - Browsers also rely on semantic tags to correctly render and style the page. For instance, a `<section>`
      or `<article>` is treated differently than a simple `<div>`, making it easier for browsers to parse and display
      information.
5. **Maintainability**:
    - Using semantic tags provides a logical structure, making the code more maintainable and reducing technical debt.
      It is easier to modify and update structured content when semantic tags are used.

## 2- What are void elements in HTML ?!

- HTML elements which do not have closing tags or do not need to be closed are Void elements. For
  Example <br />, <img />, <hr />, etc.

## 3- **What is the advantage of collapsing white space?**

- In HTML, a blank sequence of whitespace characters is treated as a single space character.

## 4- **What are HTML Entities?**

- In HTML some characters are reserved like ‘<’, ‘>’, ‘/’, etc. To use these characters in our webpage we need to use
  the character entities called HTML Entities.

## 5- HTML Positions !

- **Static**: Default value. Here the element is positioned according to the normal flow of the document.
- **Absolute**: Here the element is positioned relative to its parent element. The final position is determined by the
  values of left, right, top, bottom.
- **Fixed**: This is similar to absolute except here the elements are positioned relative to the <html> element.
- **Relative**: Here the element is positioned according to the normal flow of the document and positioned relative to
  its original/ normal position.
- **Initial**: This resets the property to its default value.
- **Inherit**: Here the element inherits or takes the property of its parent.

## 6- HTML Display !

- **Inline**: Using this we can display any block-level element as an inline element. The height and width attribute
  values of the element will not affect.
- **Block**: using this, we can display any inline element as a block-level element.
- **Inline-block**: This property is similar to inline, except by using the display as inline-block, we can actually
  format the element using height and width values.
- **Flex**: It displays the container and element as a flexible structure. It follows flexbox property.
- **Inline-flex**: It displays the flex container as an inline element while its content follows the flexbox properties.
- **Grid**: It displays the HTML elements as a grid container.
- **None**: Using this property we can hide the HTML element.

## 7- **Difference between SVG and Canvas HTML5 element?**

- SVG:
    - SVG is a vector based i.e., composed of shapes.
    - SVG works better with a larger surface.
    - SVG can be modified using CSS and scripts.
    - SVG is highly scalable. So we can print at high quality with high resolution.
- **Canvas:**
    - It is Raster based i.e., composed of pixels.
    - Canvas works better with a smaller surface.
    - Canvas can only be modified using scripts.
    - It is less scalable.
