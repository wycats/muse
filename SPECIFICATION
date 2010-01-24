# Muse-Formatted Text (MFT)

This specification hopes to define the behavior of Muse Formatted Text (or, MFT). It is an ad-hoc spec which will continual to evolve. This is currently version 0.1

## Markdown Superset

The basis for Muse is Markdown, making Muse-Formatted Text (MFT) a superset of the language.

This means that MFT will support all the typical standard Markdown structures[1] as well as the github flavor. It also supports all valid HTML tags, enabling the author to implement functional presentation elements such as tables.

MFT also implements its own subset of publishing specific elements, described here in this ad-hoc spec.

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

Authors should specify figures as `<img>` tags with the special boolean `muse-figure` attribute. A figure may also specify additional text in the title attribute. During preprocessing, a valid Muse preprocessor MUST add a paragraph tag containing an anchor tag. The paragraph tag MUST have the classes `figure` and `title`. The anchor tag must have the `name` `1-{image source}`. The anchor tag's contents MUST be `Figure {chapter}{separator}{figure number}` (for instance, `Figure 1.1`). The figure number is a sequence (see Sequences). If the author provides a title, a valid Muse processor MUST insert it after the closing anchor tag, followed by a single space.

### Example

The following Muse tag:

    <img muse-figure src="rack.png" title="A Rack Application">

MUST generate:

    <img src="rack.png" title="A Rack Application"><p class="figure title"><a name="1-rack.png">Figure 1.1</a> A Rack Application</p>
