# Muse-Formatted Text (MFT)

This specification hopes to define the behavior of Muse Formatted Text (or, MFT). It is an ad-hoc spec which will continual to evolve. This is currently version 0.1

## Markdown Superset

The basis for Muse is Markdown, making Muse-Formatted Text (MFT) a superset of the language.

This means that MFT will support all the typical standard Markdown structures[1] as well as the github flavor. It also supports all valid HTML tags, enabling the author to implement functional presentation elements such as tables.

MFT also implements its own set of publishing specific elements, described here in this ad-hoc spec.

## Conversion Process

To convert a muse-formatted document to HTML, first convert it to Markdown, the convert that Markdown to HTML. This document specifies how to emit Markdown; from there we suggest Maruku.

# Language Definition

These headings define how the language is properly defined.

## Tags

Muse tags look and behave like HTML tags. Like HTML tags, Muse tags may be self-closing, and may contain shorthand boolean attributes. Muse specifically follows the HTML 4 definition as provided by the W3C.

## Chapters

A chapter of Muse-formatted text begins with a heading at a single level of nesting (`#`). The titles of Figures, Listings, Tables and other Muse constructs are labeled using the current chapter number. For example, the first figure of the first chapter gets the title "Figure 1.1" followed by the author-specified title.

## Sequences

Chapters, Figures, Listings, Tables and other Muse constructs have incrementing numbers. For instance, the first chapter might be labeled "Chapter 1", followed by "Chapter 2". In turn, the first figure of a chapter might be labeled "Figure 1.1", followed by "Figure 1.2".

The default style for sequences is 1.1, 1.2, 2.1, 2.2. The author may choose an alternate scheme for their sequences, such as A-Z, i-x, etc. However the sequence resets with each chapter: therefore if the first chapter is sequence 1, then the second is sequence 2. Figures and other constructs then are 1.1, 1.2, and reset similarly for each chapter.

// TODO: How to specify alternative styles for constructs and levels of nesting

## Headings

Authors should use Markdown-style headings in MFT documents. A valid Muse processor MUST prepend heading names with numbers. The style of each level of nesting MAY be specified by the author (see Sequences).

## Figures

Authors should specify figures as `<figure>` tags. A figure may also specify additional text in the title attribute. During preprocessing, a valid Muse preprocessor MUST add a paragraph tag containing an anchor tag. The paragraph tag MUST have the classes `figure` and `title`. The anchor tag must have the `name` `1-figure-{image source}`. The anchor tag's contents MUST be `Figure {chapter}{separator}{figure number}` (for instance, `Figure 1.1`). The figure number is a sequence (see Sequences). If the author provides a title, a valid Muse processor MUST insert it after the closing anchor tag, followed by a single space.

### Example

The following Muse tag:

    <figure src="rack.png" title="A Rack Application">

MUST generate:

    <img src="rack.png" title="A Rack Application"><p class="figure title"><a name="1-figure-rack.png">Figure 1.1</a> A Rack Application</p>

## Notes

Authors should specify notes as `<note>` tags. A valid Muse preprocessor MUST convert notes to `<div>` tags with the class `note` and a `data-type` attribute of `note`. The `<div>` MUST contain two `<p>` tags. The first `<p>` MUST have a class of `note_head` and contain the text `Note`. The second `<p>` MUST contain the text originally between the start and end of the `<note>`.

### Example

The following Muse tag:

    <note>Hello World</note>

MUST generate:

    <div class='note' data-type='note'><p class='note_head'>Note</p><p>Hello World</p></div>

## Other Notes

Authors may specify other kinds of notes by including a single boolean flag in the `<note>` tag specifying the kind of note. For instance, an author may specify a TODO by using `<note todo>`. If an author specifies such a boolean attribute, a Muse preprocessor MUST generate a note as above, with the following changes: the `type` attribute of the `<div>` MUST be the same as the text of the boolean flag, and the contents of the first `p` MUST be the text of the boolean flag capitalized. If the flag has hyphens, a Muse preprocessor MUST replace them with spaces, and it MUST capitalize each word.

A Muse preprocessor MUST treat a bare `<note>` tag as identical to `<note note>`.

### Example

The following Muse tag:

    <note TODO>Fix this</note>

MUST generate:

    <div class='note' data-type='TODO'><p class='note_head'>TODO</p><p>Fix this</p></div>

And the following Muse tag:

    <note fix-this>Come on! Fix it!</note>

MUST generate:

    <div class='note' data-type='fix-this'><p class='note_head'>Fix This</p><p>Come on! Fix it!</p></div>

## Listings

An author can designate some text as a listing with the `<listing>` tag. A Muse preprocessor MUST insert the contents of a listing inside a `<pre>` with the `class` of `listing`. If an author specifies a `lang` attribute, a Muse processor MUST use the program specified in the metadata section to convert the contents of the `<listing>` into syntax-highlighted markup. If the author does not designate a program, a Muse processor MAY use a default program, or it MAY ignore the attribute.

An author MAY also provide a git ref (as a `ref` attribute), file (as a `file` attribute), and optional start and end numbers (as a `start` attribute and an `end` attribute) instead of inserting the contents inline. If an author specifies a `ref` attribute, he MUST specify a `file` attribute. If an author specifies a `file` attribute but no `ref` attribute, a Muse preprocessor MUST use the `HEAD` ref.

If an author specifies a `start` attribute, he MUST specify an `end` attribute. An author MUST NOT specify a `ref` attribute but no `file` attribute, a `start` attribute but no `end` attribute, or and `end` attribute with no `start` attribute. An author MUST NOT specify a `start` or `end` attribute if he does not specify a `file` attribute.

An author MAY specify the location of the repository to use for listings in the metadata. If no location is specified, a Muse preprocessor SHOULD use the `src` directory under the git repository containing the text of the document.

On the line after the closing `</pre>`, a Muse preprocessor MUST insert a `<p>` tag with `listing` and `title` classes. A Muse preprocessor must insert an `<a>` tag inside the `<p>` tag. The `<a>` tag MUST have a name of `{chapter}-listing-{name}`.

An author MUST specify a `name` attribute for the listing. An author MAY specify a `title` attribute for a listing. A Muse preprocessor MUST insert the `title` attribute immediately following the closing `<a>` tag, preceded by a space.

### Whitespace Handling

A Muse preprocessor MUST remove any whitespace immediately following the `<listing>` tag until the first line with non-whitespace characters. A Muse preprocessor MUST remove the last newline followed by a line containing only whitespace followed by the `</listing>` closing tag.

### Example

The following Muse tag:

    <listing name="muse" title="A Muse Class">
    class Muse

    end
    </list>

MUST generate:

    <pre>class Muse

    end</pre>
    <p class="listing title"><a name="1-listing-muse">Listing 1.1</a> A Muse Class</p>

OR an appropriately syntax highlighted version of the same content.

## References

An author can reference any construct with a sequence with the `<ref>` tag. The ref tag MUST has `type` and `name` attributes, where `type` refers to the type of construct (such as `figure` or `listing`) and `name` refers to the name the author gave to the specific instance of the construct.

### Example

The following Muse tags:

    <figure src="rack.png" title="A Rack Application">
    See <ref type="figure" name="rack.png">.

MUST generate:

    <img src="rack.png" title="A Rack Application"><p class="figure title"><a name="1-figure-rack.png">Figure 1.1</a> A Rack Application</p>
    See <a href="#1-figure-rack.png">Figure 1.1</a>.

## Metadata Section

An author may specify optional metadata. A Muse preprocessor MUST use this metadata as described in other parts of this specification. A must preprocessor MAY support additional metadata for other purposes.

Metadata MUST be enclosed in a `<metadata>` tag, and if supplied, author MUST place it first in a Muse document. An author may supply only one `<metadata>` section for an entire document.