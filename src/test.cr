require "./Single"

sources = [
  Single(String).just("World"),
  Single(String).just("Alexis"),
  Single(String).just("John"),
  Single(String).just("Doe"),
  Single(String).just("Hello"),
] of SingleSource(String);

Single(String).amb(sources).subscribe(->(x : String){ puts x })