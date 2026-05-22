import React from 'react';
import { Toaster } from "react-hot-toast";
import AppRouter from './Core/Constants/AppRouter.jsx';
import Sidebar from './Core/Components/SideBar.jsx';
import { useLocation } from "react-router-dom";
import { AuthProvider } from './Core/Context/AuthContext.jsx';
import { DashboardProvider } from './Core/Context/DashboardContext.jsx';
import { UsersProvider } from './Core/Context/UserContext.jsx';
import { BooksProvider } from './Core/Context/BooksContext.jsx';
import { AuthorProvider } from './Core/Context/AuthorContext.jsx';
import { CategoryProvider } from './Core/Context/CategoriesContext.jsx';
import { WaitingListProvider } from './Core/Context/WaitingListContext.jsx';
import { TransactionsProvider } from './Core/Context/TransactionsContext.jsx';
import { BillsProvider } from './Core/Context/BillContext.jsx';
function App() {
  const location = useLocation();

  const hideSidebar = location.pathname === "/";

  return (
    <>
      {!hideSidebar && <Sidebar />}

      <main style={{ minHeight: "100vh", display: "block" }}>
          <AuthProvider>
  <DashboardProvider>
    <UsersProvider>
      <BooksProvider>
        <AuthorProvider>
          <CategoryProvider>
            <WaitingListProvider>
              <TransactionsProvider>
                <BillsProvider>
                  <AppRouter />
                </BillsProvider>
              </TransactionsProvider>
            </WaitingListProvider>
          </CategoryProvider>
        </AuthorProvider>
      </BooksProvider>
    </UsersProvider>
  </DashboardProvider>
</AuthProvider>

      </main>

      <Toaster position="top-right" />
    </>
  );
}

export default App;

