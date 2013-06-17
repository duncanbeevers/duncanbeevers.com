----
----

Ever have to map all the keys of a Hash, or Hash-like Ruby object? For example, you have a Hash mapping keys to the binary contents of several files, and you want to present those file contents as Base64.

Imagine we have a Hash that looks something like this:

````ruby
pictures_hash = {
  'goblins' => PICTURE_OF_GOBLINS,
  'kittens' => PICTURE_OF_KITTENS
}
````
