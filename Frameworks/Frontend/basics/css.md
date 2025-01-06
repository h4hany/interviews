# CSS & SCSS:

## 1- **What is the Box model in CSS? Which CSS properties are a part of it?**

- A rectangle box is wrapped around every HTML element. The box model is used to determine the height and width of the
  rectangular box. The CSS Box consists of Width and height (or in the absence of that, default values and the content
  inside), padding, borders, margin.

## 2- **What are Pseudo classes?**

- Pseudo-classes are the type of pseudo-elements that don’t exist in a normal document tree. It allows selecting the
  regular elements under certain conditions especially when we try to hover over the link; the anchor tags are :link, :
  visited, :hover, :active, :focus.

## 3- **What are the differences between adaptive design and responsive design?**

- **Adaptive Design:**
    - Main focus is to develop a website in multiple fixed layout sizes.
    - Offers good control over the design to develop variation in screens.
    - It is very time-consuming and takes a lot of effort to build the best possible adaptive design as examining it
      will need to go for many options with respect to the realities of the end user.
    - There are six standard screen sizes for the appropriate layouts; they are 320px, 480px, 760px, 960px, 1200px,
      1600px to design.
- **Responsive Design:**
    - Main focus is to show content with respect to browser space.
    - Offers less control over the design.
    - It takes less time to build the design and there is no screen size issue irrespective of content.
    - It uses CSS media queries to design the screen layouts with respect to specific devices and property changes in
      the screen.

## 4- **Difference between CSS grid vs flexbox ?**

- CSS Grid Layout is a two-dimensional system along with rows and columns. It is used for large-sized layouts.
- Flexbox is a Grid layout with a one-dimensional system either within a row or a column. It is used for the components
  of an application.

## 5- **Explain what is Sass ?**

- Sass stands for Syntactically Awesome Stylesheets and was created by Hampton Catlin. It is an extension of CSS3,
  adding nested rules, mixins, variables, selector inheritance, etc.

## 6- **Explain how to define a variable in Sass ?**

- Variables in Sass begin with a ($) sign and variable assignment is done with a colon(:).

## 7- **What Selector Nesting in Sass is used for ?**

- In Sass, selector nesting offers a way for stylesheet authors to compute long selectors by nesting shorter selectors
  within each other.

## 8- **Explain what is a @extend function used for in Sass ?**

- In Sass, the @EXTEND directive provides a simple way to allow a selector to inherit the styles of another one. It aims
  at providing a way for a selector A to extend the styles from a selector B. When doing so, the selector A will be
  added to selector B so they both share the same declarations. @EXTEND prevents code bloat by grouping selectors that
  share the same style into one rule.

## 9-  **Explain what is the use of the @IMPORT function in Sass ?**

The @IMPORT function in Sass:

- Extends the CSS import rule by enabling import of SCSS and Sass files.
- All imported files are merged into a single outputted CSS file.
- Can virtually mix and match any file and be certain of all your styles.
- @IMPORT takes a filename to import.

## 10- **Explain what is the use of Mixin function in Sass ? What is the meaning of DRY-ing out a Mixin ?**

- Mixin allows you to define styles that can be re-used throughout the stylesheet without needing to resort to
  non-semantic classes like .float-left.
- DRY-ing out of a mixing means splitting it into dynamic and static parts. The dynamic mixin is the one that the user
  actually going to call, and the static mixin is the pieces of information that would otherwise get duplicated.
