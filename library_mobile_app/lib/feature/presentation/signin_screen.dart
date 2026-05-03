import 'package:flutter/material.dart';
import 'package:library_mobile_app/core/constant.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/presentation/register.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),

                    Image.asset("assets/logo.png", height: 200),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone_android_rounded),
                        prefixIconColor: AppColors.iconscol,
                        hintText: "Enter Phone Number",
                        hintStyle: TextStyle(color: AppColors.textGrey),
                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    TextField(
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_open),
                        prefixIconColor: AppColors.iconscol,
                        hintStyle: TextStyle(color: AppColors.textGrey),
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(Routes.homePage);
                        },
                        child: Text(
                          "login",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "I foregot password",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 199, 16, 16),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => Register(),
                              ),
                            );
                          },
                          child: Text(
                            "I dont have accont",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 5, 110, 197),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    socialButton(
                      text: "Google",
                      asset: "assets/google.png",
                      bgColor: Colors.white,
                      textColor: Colors.black,
                      border: true,
                    ),

                    SizedBox(height: 12),

                    socialButton(
                      text: "Facebook",
                      asset: "assets/facebook.png",
                      bgColor: Color.fromARGB(255, 24, 79, 152),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 12),

                socialButton(
                  text: "Apple",
                  asset: "assets/apple.png",
                  bgColor: const Color.fromARGB(255, 255, 255, 255),
                  textColor: const Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget socialButton({
    required String text,
    required String asset,
    required Color bgColor,
    required Color textColor,
    bool border = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      width: 150,
      height: 45,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: border ? Border.all(color: Colors.grey.shade300) : null,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, height: 32),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
