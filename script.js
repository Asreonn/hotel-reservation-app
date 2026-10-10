document.addEventListener('DOMContentLoaded', function() {
    // Oda seçimi için değişkenler
    const roomCards = document.querySelectorAll('.room-card');
    let selectedRoom = null;

    // Oda seçimi işlevi
    roomCards.forEach(card => {
        card.addEventListener('click', function() {
            if (selectedRoom) {
                selectedRoom.classList.remove('selected');
            }
            this.classList.add('selected');
            selectedRoom = this;
        });
    });

    // Form gönderimi
    const reservationForm = document.getElementById('reservationForm');
    reservationForm.addEventListener('submit', function(e) {
        e.preventDefault();

        if (!selectedRoom) {
            alert('Lütfen bir oda seçiniz!');
            return;
        }

        const reservation = {
            name: document.getElementById('name').value,
            checkIn: document.getElementById('checkIn').value,
            checkOut: document.getElementById('checkOut').value,
            guests: document.getElementById('guests').value,
            roomType: selectedRoom.getAttribute('data-room')
        };

        // Rezervasyonu localStorage'a kaydet
        saveReservation(reservation);
        
        // Formu sıfırla
        reservationForm.reset();
        selectedRoom.classList.remove('selected');
        selectedRoom = null;

        alert('Rezervasyonunuz başarıyla kaydedildi!');
    });

    // Rezervasyon kaydetme fonksiyonu
    function saveReservation(reservation) {
        let reservations = JSON.parse(localStorage.getItem('reservations')) || [];
        reservations.push(reservation);
        localStorage.setItem('reservations', JSON.stringify(reservations));
    }

    // Geçmiş rezervasyonlar modalı
    const modal = document.getElementById('historyModal');
    const showHistoryBtn = document.getElementById('showHistory');
    const closeBtn = document.querySelector('.close');
    const reservationHistory = document.getElementById('reservationHistory');

    showHistoryBtn.addEventListener('click', function() {
        displayReservations();
        modal.style.display = 'block';
    });

    closeBtn.addEventListener('click', function() {
        modal.style.display = 'none';
    });

    window.addEventListener('click', function(e) {
        if (e.target === modal) {
            modal.style.display = 'none';
        }
    });

    // Rezervasyonları görüntüleme fonksiyonu
    function displayReservations() {
        const reservations = JSON.parse(localStorage.getItem('reservations')) || [];
        reservationHistory.innerHTML = '';

        if (reservations.length === 0) {
            reservationHistory.innerHTML = '<p>Henüz rezervasyon bulunmamaktadır.</p>';
            return;
        }

        reservations.forEach((reservation, index) => {
            const reservationItem = document.createElement('div');
            reservationItem.className = 'reservation-item';
            reservationItem.innerHTML = `
                <h3>Rezervasyon #${index + 1}</h3>
                <p><strong>Ad Soyad:</strong> ${reservation.name}</p>
                <p><strong>Oda Tipi:</strong> ${reservation.roomType}</p>
                <p><strong>Giriş Tarihi:</strong> ${reservation.checkIn}</p>
                <p><strong>Çıkış Tarihi:</strong> ${reservation.checkOut}</p>
                <p><strong>Kişi Sayısı:</strong> ${reservation.guests}</p>
            `;
            reservationHistory.appendChild(reservationItem);
        });
    }

    // Tarih kontrolü
    const checkInInput = document.getElementById('checkIn');
    const checkOutInput = document.getElementById('checkOut');

    checkInInput.addEventListener('change', function() {
        checkOutInput.min = this.value;
        if (checkOutInput.value && checkOutInput.value < this.value) {
            checkOutInput.value = this.value;
        }
    });

    checkOutInput.addEventListener('change', function() {
        if (this.value < checkInInput.value) {
            alert('Çıkış tarihi giriş tarihinden önce olamaz!');
            this.value = checkInInput.value;
        }
    });
}); 