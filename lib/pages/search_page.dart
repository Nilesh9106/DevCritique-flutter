import 'package:devcritique/components/project_card.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/projects/project_service.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<Project> _searchResults = [];
  bool _isLoading = false;

  searchProject(query) async {
    setState(() {
      _isLoading = true;
    });
    _searchResults = await ProjectService.searchProject(query);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  Color.fromRGBO(12, 12, 12, 1),
                  Colors.black,
                ]
              : [
                  Colors.grey[200]!,
                  Colors.white,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                collapsedHeight: 80,
                expandedHeight: 80,
                floating: true,
                backgroundColor: Colors.transparent,
                // pinned: true,
                scrolledUnderElevation: 0,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          String query = _searchController.text.trim();
                          if (query.isNotEmpty) {
                            print(query);
                            searchProject(query);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _searchResults.isEmpty
                            ? const Center(child: Text('No results found.'))
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: _searchResults.length,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ProjectWidget(
                                      project: _searchResults[index]);
                                },
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
