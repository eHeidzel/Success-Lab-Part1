document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('webToLeadForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const isValid = validateForm();
        
        if (isValid) {
            this.submit();
        }
    });

    document.getElementById('phone').addEventListener('input', function(e) {
        let value = this.value.replace(/\D/g, '');
        if (!value.startsWith('375') && value.length > 0) {
            value = '375' + value;
        }
        this.value = value.substring(0, 12);
    });

    // Основная функция валидации
    function validateForm() {
        let isValid = true;
        
        isValid &&= validateTextField('company', 'Название компании должно содержать минимум 3 буквы');
        isValid &&= validateTextField('first_name', 'Имя должно содержать минимум 3 буквы');
        isValid &&= validateTextField('last_name', 'Фамилия должна содержать минимум 3 буквы');
        isValid &&= validateEmail();
        isValid &&= validatePhone();
        isValid &&= validateProduct();

        if(grecaptcha.getResponse().length === 0) {
            document.getElementById('recaptcha-error').style.display = 'block';
            isValid = false;
        } else {
            document.getElementById('recaptcha-error').style.display = 'none';
        }
        
        return isValid;
    }

    function validateTextField(fieldId, errorMessage) {
        const field = document.getElementById(fieldId);
        const errorElement = document.getElementById(`${fieldId}-error`);
        
        if (!field.value.trim() || field.value.trim().length < 3) {
            showError(field, errorElement, errorMessage);
            return false;
        } else {
            hideError(field, errorElement);
            return true;
        }
    }

    function validateEmail() {
        const email = document.getElementById('email');
        const emailError = document.getElementById('email-error');
        
        if (!email.value || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
            showError(email, emailError, 'Пожалуйста, введите корректный email');
            return false;
        } else {
            hideError(email, emailError);
            return true;
        }
    }

    // Валидация телефона (формат 375XXXXXXXX)
    function validatePhone() {
        const phone = document.getElementById('phone');
        const phoneError = document.getElementById('phone-error');
        
        if (!phone.value || !/^375\d{9}$/.test(phone.value)) {
            showError(phone, phoneError, 'Телефон должен быть в формате 375XXXXXXXX (12 цифр)');
            return false;
        } else {
            hideError(phone, phoneError);
            return true;
        }
    }

    function validateProduct() {
        const product = document.getElementById('00NgK000012Ba6X');
        const productError = document.getElementById('product-error');
        
        if (!product.value) {
            showError(product, productError, 'Пожалуйста, выберите продукт');
            return false;
        } else {
            hideError(product, productError);
            return true;
        }
    }

    function showError(field, errorElement, message) {
        field.style.borderColor = '#e74c3c';
        errorElement.textContent = message;
        errorElement.style.display = 'block';
    }

    function hideError(field, errorElement) {
        field.style.borderColor = '#ddd';
        errorElement.style.display = 'none';
    }
});