import {  Routes, Route } from "react-router-dom";
import AdminLoginPage from "../JS/AdminLogin";
import Dashboard from "../JS/DashBoard";
import UsersPage from "../JS/Users";
import ActionsPage from "../JS/Actions";
import AddBookPage from "../JS/AddNewBook";
import AnalyticsPage from "../JS/AnalyistPage";
import FinancePage from "../JS/Finance";
import ArchivesPage from "../JS/Archives";
import CirculationPage from "../JS/Barrow";
import LibraryInventoryPage from "../JS/LibraryInventorPage";
import NotificationsPage from "../JS/Notification";
import LibrarySettings from "../JS/Setting";

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

    </Routes>
);
}