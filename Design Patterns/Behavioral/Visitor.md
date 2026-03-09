# Visitor Pattern - Complete Guide

## What is the Visitor Pattern?

The **Visitor Pattern** represents an operation to be performed on elements of an object structure. It lets you define new operations without changing the classes of the elements.

## When to Use Visitor Pattern

**Use Visitor Pattern when:**
- ✅ You need to perform operations on object structure
- ✅ Operations vary but object structure is stable
- ✅ You want to add new operations without modifying classes
- ✅ Operations need to work with different element types
- ✅ Object structure has many different types

## How to Recognize the Problem

**Red Flags:**
- You need to add operations to object structure
- Operations are scattered across classes
- Adding new operation requires modifying many classes
- "I need to perform different operations on the same structure"

## Real-World Example: Document Export

### Problem: Without Visitor

```ruby
class Document
  def initialize
    @elements = []
  end
  
  def add(element)
    @elements << element
  end
  
  def export_to_pdf
    @elements.each do |element|
      case element
      when Text
        # PDF export for text
      when Image
        # PDF export for image
      when Table
        # PDF export for table
      end
    end
  end
  
  def export_to_html
    @elements.each do |element|
      case element
      when Text
        # HTML export for text
      when Image
        # HTML export for image
      when Table
        # HTML export for table
      end
    end
  end
  
  # Problem: Adding new export format requires modifying this class
end
```

### Solution: With Visitor

```ruby
# Element interface
class Element
  def accept(visitor)
    raise NotImplementedError
  end
end

# Concrete elements
class Text < Element
  attr_reader :content
  
  def initialize(content)
    @content = content
  end
  
  def accept(visitor)
    visitor.visit_text(self)
  end
end

class Image < Element
  attr_reader :src
  
  def initialize(src)
    @src = src
  end
  
  def accept(visitor)
    visitor.visit_image(self)
  end
end

class Table < Element
  attr_reader :data
  
  def initialize(data)
    @data = data
  end
  
  def accept(visitor)
    visitor.visit_table(self)
  end
end

# Visitor interface
class Visitor
  def visit_text(text)
    raise NotImplementedError
  end
  
  def visit_image(image)
    raise NotImplementedError
  end
  
  def visit_table(table)
    raise NotImplementedError
  end
end

# Concrete visitors
class PDFExportVisitor < Visitor
  def visit_text(text)
    puts "Exporting text '#{text.content}' to PDF"
  end
  
  def visit_image(image)
    puts "Exporting image '#{image.src}' to PDF"
  end
  
  def visit_table(table)
    puts "Exporting table to PDF"
  end
end

class HTMLExportVisitor < Visitor
  def visit_text(text)
    puts "<p>#{text.content}</p>"
  end
  
  def visit_image(image)
    puts "<img src='#{image.src}'>"
  end
  
  def visit_table(table)
    puts "<table>...</table>"
  end
end

class XMLExportVisitor < Visitor
  def visit_text(text)
    puts "<text>#{text.content}</text>"
  end
  
  def visit_image(image)
    puts "<image src='#{image.src}'/>"
  end
  
  def visit_table(table)
    puts "<table>...</table>"
  end
end

# Object structure
class Document
  def initialize
    @elements = []
  end
  
  def add(element)
    @elements << element
  end
  
  def accept(visitor)
    @elements.each { |element| element.accept(visitor) }
  end
end

# Usage
document = Document.new
document.add(Text.new("Hello"))
document.add(Image.new("photo.jpg"))
document.add(Table.new([[]]))

# Different visitors for different operations
pdf_visitor = PDFExportVisitor.new
document.accept(pdf_visitor)

html_visitor = HTMLExportVisitor.new
document.accept(html_visitor)

# Easy to add new export format without modifying elements!
```

## Benefits of Visitor Pattern

1. **Open/Closed**: Add new operations without modifying classes
2. **Separation**: Operations separated from object structure
3. **Flexibility**: Different visitors for different operations
4. **Type Safety**: Visitor handles type-specific logic

## When NOT to Use Visitor Pattern

- ❌ Object structure changes frequently
- ❌ Operations are simple
- ❌ Over-engineering for simple cases

## Summary

**Visitor Pattern:**
- Separates operations from object structure
- Add new operations without modifying classes
- Use when structure is stable but operations vary
- Like having specialists visit different departments

