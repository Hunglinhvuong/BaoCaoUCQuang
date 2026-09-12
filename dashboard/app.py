import streamlit as st

from dashboard import home, incidents, map as map_page

st.set_page_config(
    page_title="Fiber Rescue Dashboard",
    page_icon="🛠️",
    layout="wide",
)

pages = {
    "📊 Tổng quan": [
        st.Page(home.render, title="Tổng quan", icon="📊", default=True),
    ],
    "🗺️ Bản đồ sự cố": [
        st.Page(map_page.render, title="Bản đồ sự cố", icon="🗺️"),
    ],
    "🚨 Sự cố": [
        st.Page(incidents.render, title="Danh sách sự cố", icon="🚨"),
    ],
}

nav = st.navigation(pages)
nav.run()
