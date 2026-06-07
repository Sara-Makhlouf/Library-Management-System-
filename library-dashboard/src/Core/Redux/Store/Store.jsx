import { configureStore } from "@reduxjs/toolkit";

import authReducer from "../Slice/AuthSlice";
import authorReducer from "../Slice/AuthorSlice";
import categoryReducer from "../Slice/CategoriesSlice";
import bookReducer from "../Slice/BooksSlice";
import dashboardReducer from "../Slice/DashbordSlice";
import waitingListReducer from "../Slice/WatingListSlice";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    authors: authorReducer,
    categories: categoryReducer,
    books: bookReducer,
    dashboard: dashboardReducer,
    waitingList: waitingListReducer,
  },
});