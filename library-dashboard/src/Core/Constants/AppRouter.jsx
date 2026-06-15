import {  Routes, Route } from "react-router-dom";
import AdminLoginPage from "../../Features/pages/AdminLogin";
import Dashboard from "../../Features/pages/DashBoard";
import UsersPage from "../../Features/pages/Users";
import AddBookPage from "../../Features/pages/AddNewBook";
import AnalyticsPage from "../../Features/pages/AnalyistPage";
import LibraryInventoryPage from "../../Features/pages/LibraryInventorPage";
import NotificationsPage from "../../Features/pages/Notification";
import LibrarySettings from "../../Features/pages/Setting";
import Orders from "../../Features/pages/Order";
import UsersListPage from "../../Features/pages/UserList";
import UserProfilePage from "../../Features/pages/UserProfile";
import BookRequestDetailsPage from "../../Features/pages/BookRequest";
import WaitingPage from "../../Features/pages/WaitingPage";
import BillsPage from "../../Features/pages/BillsPage";
import TransactionsPage from "../../Features/pages/TransactionsPage";


export default function AppRouter() {
return (
    
    <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/" element={<AdminLoginPage />} />
        <Route path="/add-book" element={<AddBookPage />} />
        <Route path="/analytics" element={<AnalyticsPage />} />
        <Route path="/" element={<AdminLoginPage />} />
        <Route path="/inventory" element={<LibraryInventoryPage />} />
        <Route path="/notifications" element={<NotificationsPage />} />
        <Route path="/settings" element={<LibrarySettings />} />
        <Route path="/order" element={<Orders />} />
        <Route path="/users/list" element={<UsersListPage />} />
        <Route path="/users/profiles" element={<UserProfilePage />} />
        <Route path="/bookrequest" element={<BookRequestDetailsPage/>} />
        <Route path="waitinglist" element={<WaitingPage/>}/>
        <Route path="/transactions" element={<TransactionsPage/>}/>
        <Route path="/bills" element={<BillsPage/>}/>
    </Routes>
);
}