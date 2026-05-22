import {  Routes, Route } from "react-router-dom";
import AdminLoginPage from "../../Features/pages/AdminLogin";
import Dashboard from "../../Features/pages/DashBoard";
import UsersPage from "../../Features/pages/Users";
import ActionsPage from "../../Features/pages/Actions";
import AddBookPage from "../../Features/pages/AddNewBook";
import AnalyticsPage from "../../Features/pages/AnalyistPage";
import FinancePage from "../../Features/pages/Finance";
import ArchivesPage from "../../Features/pages/Archives";
import CirculationPage from "../../Features/pages/Barrow";
import LibraryInventoryPage from "../../Features/pages/LibraryInventorPage";
import NotificationsPage from "../../Features/pages/Notification";
import LibrarySettings from "../../Features/pages/Setting";
import Orders from "../../Features/pages/Order";
import UsersListPage from "../../Features/pages/UserList";
import UsersCardsPage from "../../Features/pages/UserCards";
import UserProfilePage from "../../Features/pages/UserProfile";
export default function AppRouter() {
return (
    
    <Routes>
        <Route path="/" element={<AdminLoginPage />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/actions" element={<ActionsPage />} />
        <Route path="/add-book" element={<AddBookPage />} />
        <Route path="/analytics" element={<AnalyticsPage />} />
        <Route path="/archives" element={<ArchivesPage />} />
        <Route path="/circulation" element={<CirculationPage />} />
        <Route path="/finance" element={<FinancePage />} />
        <Route path="/inventory" element={<LibraryInventoryPage />} />
        <Route path="/notifications" element={<NotificationsPage />} />
        <Route path="/settings" element={<LibrarySettings />} />
        <Route path="/order" element={<Orders />} />
        <Route path="/users/list" element={<UsersListPage />} />
        <Route path="/users/cards" element={<UsersCardsPage />} />
        <Route path="/users/profiles" element={<UserProfilePage />} />

    </Routes>
);
}