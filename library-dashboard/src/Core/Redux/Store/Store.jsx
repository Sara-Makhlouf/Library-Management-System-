import { configureStore } from "@reduxjs/toolkit";

import authReducer from "../Slice/AuthSlice";
import authorReducer from "../Slice/AuthorSlice";
import categoryReducer from "../Slice/CategoriesSlice";
import bookReducer from "../Slice/BooksSlice";
import dashboardReducer from "../Slice/DashbordSlice";
import waitingListReducer from "../Slice/WatingListSlice";
import BookRequestReducer from "../Slice/BookRequestSlice";
import AdminSettingReducer from "../Slice/AdminSlice";
import TranscationReducer from "../Slice/TranscationSlice";
import UsersReducer from "../Slice/UserSlice";
import BillReducer from "../Slice/BillSlice";  
import AnalyiseReducer from "../Slice/AnalayistSlice";
import libraryReducer from "../Slice/SettingSlice";
import orderReducer from "../Slice/OrderSlice";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    authors: authorReducer,
    categories: categoryReducer,
    books: bookReducer,
    dashboard: dashboardReducer,
    waitingList: waitingListReducer,
    BookRequest: BookRequestReducer,
    AdminSetting: AdminSettingReducer,
    Transcation: TranscationReducer,
    user: UsersReducer,
    library: libraryReducer,
    Bill: BillReducer,   
    Analyise: AnalyiseReducer,
delivery: orderReducer,  },
});