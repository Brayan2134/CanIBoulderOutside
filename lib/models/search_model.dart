/// A model representing a search result.
///
/// This class holds data related to a search operation, specifically the result of the search.
class Search {

  /// The result of the search.
  ///
  /// This field holds the search result as a [String].
  final String result;

  /// Constructs an instance of [Search].
  ///
  /// This constructor initializes the [result] field with the provided value.
  ///
  /// [result] The search result string.
  Search({required this.result});
}