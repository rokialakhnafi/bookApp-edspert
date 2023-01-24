import 'dart:convert';

import 'package:book_app/models/book_detail_response.dart';
import 'package:book_app/models/book_list_response.dart';
import 'package:book_app/views/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetailBookPage extends StatefulWidget {
  const DetailBookPage({super.key, required this.isbn});
  final String isbn;

  @override
  State<DetailBookPage> createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  BookDetailResponse? detailBook;
  fetchDetailBookApi() async {
    //print(widget.isbn);
    var url = Uri.parse('https://api.itbook.store/1.0/books/${widget.isbn}');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonDetail = jsonDecode(response.body);
      detailBook = BookDetailResponse.fromJson(jsonDetail);
      setState(() {});
      fetchSimiliarBookApi(detailBook!.title!);
    }
    //print(await http.read(Uri.https('example.com', 'foobar.txt')));
  }

BookListResponse? similiarBooks;
  fetchSimiliarBookApi(String title) async {
    //print(widget.isbn);
    var url = Uri.parse('https://api.itbook.store/1.0/search/${title}');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonDetail = jsonDecode(response.body);
      similiarBooks = BookListResponse.fromJson(jsonDetail);
      setState(() {});
    }
    //print(await http.read(Uri.https('example.com', 'foobar.txt')));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDetailBookApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: detailBook == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ImageViewScreen(imageUrl: detailBook!.image!),
                            ),
                          );
                        },
                        child: Image.network(
                          detailBook!.image!,
                          height: 150,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(detailBook!.title!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),),

                              Text(detailBook!.authors!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4E4E4E),
                              ),),

                              Row(
                                 children: List.generate(5,
                                  (index) => Icon(Icons.star,
                                  color: index < int.parse(detailBook!.rating!)
                                  ? Colors.yellow
                                  : Colors.grey,
                                  )),
                              ),

                              SizedBox(height: 10,),

                              Text(detailBook!.subtitle!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 106, 106, 106),
                              ),),

                              Text(detailBook!.price!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF127D16),
                              ),),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      ),
                      onPressed: () async{
                        Uri uri = Uri.parse(detailBook!.url!);
                        try{
                          (await canLaunchUrl(uri)) ? launchUrl(uri) : print('eroor');
                        }catch(e){

                        }
                        
                      }, child: Text("Buy")),
                  ),
                  SizedBox(height: 30,),
                      Text(detailBook!.desc!),
                  SizedBox(height: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //Text(detailBook!.isbn10!),
                      Text("Year " + detailBook!.year!),
                      Text("ISBN " + detailBook!.isbn13!),
                      Text(detailBook!.pages! + " Page"),
                      Text("Publisher : " + detailBook!.publisher!),
                      Text("Language : " + detailBook!.language!),
                      //Text(detailBook!.rating!),
                    ],
                  ),
                  Divider(),
                  similiarBooks == null
                  ? CircularProgressIndicator()
                  : Container(
                    height: 180,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: similiarBooks!.books!.length,
                      //physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final current = similiarBooks!.books![index];
                        return Container(
                          width: 100,
                          child: Column(
                            children :[
                              Image.network(current.image!,
                              height: 100,),
                              Text(current.title!,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                              ),),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ),
    );
  }
}
