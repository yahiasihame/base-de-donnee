import streamlit as st
import mysql.connector
from datetime import date
import pandas as pd

def get_connection():
    return mysql.connector.connect(
        host="yahia-Asihame.local",
        user="root",
        password="Yahya.sihame.9",
        database="HotelDB",
        port=3306
    )

st.title("🏨 Gestion Hôtel")
st.markdown("---")

menu = st.sidebar.selectbox("📋 Menu", [
    "Liste des clients",
    "Liste des réservations",
    "Chambres disponibles",
    "Ajouter un client",
    "Ajouter une réservation"
])

def fetch_as_dataframe(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params or ())
    columns = [desc[0] for desc in cursor.description]
    data = cursor.fetchall()
    cursor.close()
    conn.close()
    return pd.DataFrame(data, columns=columns)

def style_dataframe(df):
    # تلوين الصفوف بالتناوب: لون خلفية أزرق فاتح للصفوف الزوجية
    return df.style.apply(lambda x: ['background-color: #E6F2FF' if i%2==0 else '' for i in range(len(x))], axis=0) \
                   .set_properties(**{'text-align': 'center'}) \
                   .set_table_styles([{
                       'selector': 'th',
                       'props': [('background-color', '#0d6efd'), ('color', 'white'), ('text-align', 'center')]
                   }])

if menu == "Liste des clients":
    st.subheader("👤 Liste des clients")
    df = fetch_as_dataframe("SELECT * FROM Client")
    st.dataframe(style_dataframe(df), use_container_width=True)

elif menu == "Liste des réservations":
    st.subheader("📅 Liste des réservations")
    query = """
        SELECT R.id AS 'ID Réservation', C.nom_complet AS 'Client', H.ville AS 'Ville Hôtel',
               R.date_debut AS 'Date Début', R.date_fin AS 'Date Fin'
        FROM Reservation R
        JOIN Client C ON R.id_client = C.id
        JOIN Chambre CH ON R.id_chambre = CH.id
        JOIN Hotel H ON CH.id_hotel = H.id
        ORDER BY R.date_debut DESC
    """
    df = fetch_as_dataframe(query)
    st.dataframe(style_dataframe(df), use_container_width=True)

elif menu == "Chambres disponibles":
    st.subheader("🛏️ Chambres disponibles")
    debut = st.date_input("Date de début", date(2025, 7, 1))
    fin = st.date_input("Date de fin", date(2025, 7, 5))

    if st.button("Rechercher"):
        query = """
            SELECT * FROM Chambre
            WHERE id NOT IN (
                SELECT id_chambre
                FROM Reservation
                WHERE (%s BETWEEN date_debut AND date_fin)
                   OR (%s BETWEEN date_debut AND date_fin)
            )
        """
        df = fetch_as_dataframe(query, (debut, fin))
        if df.empty:
            st.info("Aucune chambre disponible pour ces dates.")
        else:
            st.dataframe(style_dataframe(df), use_container_width=True)

elif menu == "Ajouter un client":
    st.subheader("➕ Ajouter un nouveau client")

    with st.form("form_ajout_client", clear_on_submit=True):
        nom = st.text_input("Nom complet")
        adresse = st.text_input("Adresse")
        ville = st.text_input("Ville")
        code_postal = st.number_input("Code postal", step=1, format="%d")
        email = st.text_input("Email")
        telephone = st.text_input("Téléphone")
        submitted = st.form_submit_button("Ajouter")

    if submitted:
        if nom.strip() == "":
            st.error("Le nom complet est requis.")
        else:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT MAX(id) + 1 FROM Client")
            new_id = cursor.fetchone()[0] or 1
            query = """
                INSERT INTO Client (id, adresse, ville, code_postal, email, telephone, nom_complet)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query, (new_id, adresse, ville, code_postal, email, telephone, nom))
            conn.commit()
            cursor.close()
            conn.close()
            st.success("Client ajouté avec succès ✅")

elif menu == "Ajouter une réservation":
    st.subheader("📝 Ajouter une réservation")

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, nom_complet FROM Client")
    clients = cursor.fetchall()
    cursor.execute("SELECT id FROM Chambre")
    chambres = cursor.fetchall()
    cursor.close()
    conn.close()

    with st.form("form_ajout_reservation", clear_on_submit=True):
        client_id = st.selectbox("Client", options=[(c[0], c[1]) for c in clients], format_func=lambda x: x[1])
        chambre_id = st.selectbox("Chambre", options=[c[0] for c in chambres])
        date_debut = st.date_input("Date début")
        date_fin = st.date_input("Date fin")
        submitted = st.form_submit_button("Ajouter réservation")

    if submitted:
        if date_debut > date_fin:
            st.error("La date de début doit être avant la date de fin.")
        else:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT MAX(id) + 1 FROM Reservation")
            new_id = cursor.fetchone()[0] or 1
            query = """
                INSERT INTO Reservation (id, date_debut, date_fin, id_client, id_chambre)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query, (new_id, date_debut, date_fin, client_id[0], chambre_id))
            conn.commit()
            cursor.close()
            conn.close()
            st.success("Réservation ajoutée avec succès ✅")
