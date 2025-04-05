enum SearchOption { SearchByName, SearchByEmail, SearchByContactNo }

SearchOption getSearchOption(int searchIndex) {
  SearchOption option = SearchOption.SearchByName;
  switch (searchIndex) {
    case 0:
      option = SearchOption.SearchByName;
      break;
    case 1:
      option = SearchOption.SearchByEmail;
      break;
    case 2:
      option = SearchOption.SearchByContactNo;
      break;
  }
  return option;
}
