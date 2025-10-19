**Name		:	Zaid Ali**  
**Reg\#		:	FA23-BCS-170**  
**Section	:	C**

# **Mobile App Development (G1)**

**Midterm Project**

# **Flutter E-Commerce App with Firebase Admin Panel**

A full-featured, modern e-commerce mobile application built with Flutter and backed by Firebase. This project provides a complete user-facing storefront as well as a powerful, integrated admin panel for managing products, orders, users, and viewing sales reports.

## **✨ Features**

A comprehensive set of features provides a complete e-commerce experience for both customers and administrators.

### **👤 Customer Features**

* **Secure Authentication:** Professional Login and Sign Up pages using Firebase Authentication (Email & Password).  
* **Dynamic Product Catalog:** Browse all available products, fetched in real-time from Firestore.  
* **Instant Search:** Find products quickly with a real-time search bar that filters the product list.  
* **Product Details Page:** Tap on any product to view its detailed description and price.  
* **Mock Purchase Flow:** A complete "Buy Now" flow that simulates a payment process.  
* **Dummy JazzCash Integration:** A dedicated payment page to confirm orders using a dummy JazzCash number.  
* **Order Persistence:** All successful orders are saved directly to the Firestore database.

### **🚀 Admin Features**

* **Admin-Specific Access:** The admin panel is only visible and accessible to a pre-defined admin email (admin@example.com).  
* **Tabbed Interface:** A clean, multi-tabbed dashboard for easy management.  
* **Reports & Revenue Dashboard:**  
  * View **Total Revenue**, **Total Orders**, and **Average Order Value**.  
  * See a ranked list of **Top Selling Products** to track performance.  
* **Order Management:**  
  * View a real-time list of all customer orders, sorted by date.  
  * Delete orders directly from the panel.  
* **Product Management (CRUD):**  
  * View all products currently in the store.  
  * **Add** new products to the catalog.  
  * **Edit** the details (name, price, description) of existing products.  
  * **Delete** products from the store.  
* **User Management:**  
  * View a list of all registered users and their sign-up date.

## **🛠️ Tech Stack**

* **Framework:** [Flutter](https://flutter.dev/)  
* **Backend & Database:** [Firebase](https://firebase.google.com/)  
  * **Firebase Authentication:** For user sign-up and login.  
  * **Cloud Firestore:** As the primary NoSQL database for products, orders, and users.  
* **State Management:** StatefulWidget & StreamBuilder for real-time data updates.  
* **UI & Styling:** Custom dark theme with [Google Fonts (Poppins)](https://fonts.google.com/specimen/Poppins).

## **⚙️ Setup and Installation**

Follow these steps to get the project up and running on your local machine.

### **Prerequisites**

* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.  
* A [Firebase](https://firebase.google.com/) project.  
* [Firebase CLI](https://firebase.google.com/docs/cli) installed (npm install \-g firebase-tools).

### **1\. Clone the Repository**

git clone \[https://github.com/your-username/flutter\_ecommerce\_app.git\](https://github.com/your-username/flutter\_ecommerce\_app.git)  
cd flutter\_ecommerce\_app

### **2\. Configure Firebase**

This project uses a .gitignore to keep the firebase\_options.dart file private. You must generate your own.

* Run the FlutterFire configuration tool in the project root:  
  flutterfire configure

* Follow the CLI prompts to connect the app to your own Firebase project. This will automatically generate the lib/firebase\_options.dart file.

### **3\. Set Up Firestore Database**

* In your Firebase Console, navigate to **Firestore Database** and create a new database.  
* Start in **Test Mode** for initial development.  
* **Crucially, you must manually create the products collection:**  
  1. Click **\+ Start collection** and name it products.  
  2. Add your first document with an **Auto-ID**.  
  3. Add the required fields: name (String), price (Number), imageUrl (String), and description (String).  
  4. The users and orders collections will be created automatically by the app.

### **4\. Run the App**

\# Get all the dependencies  
flutter pub get

\# Run the application  
flutter run

## **🔑 Admin Access**

To access the powerful admin panel:

1. Sign up for a new account in the app using the email: admin@example.com  
2. You can use any password you like.  
3. Log in with these credentials. An "Admin Panel" icon will now appear in the app bar on the home screen.

## **License**

This project is licensed under the MIT License \- see the [LICENSE.md](http://docs.google.com/LICENSE.md) file for details.