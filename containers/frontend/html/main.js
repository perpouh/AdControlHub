document.addEventListener('DOMContentLoaded', function() {
  const form = document.getElementById('register-form');
  const emailInput = document.getElementById('email');
  const errorMessage = document.getElementById('error-message');

  form.addEventListener('submit', async function(e) {
    e.preventDefault();
    errorMessage.textContent = '';
    const email = emailInput.value.trim();
    if (!validateEmail(email)) {
      errorMessage.textContent = '正しいメールアドレスを入力してください。';
      return;
    }
    try {
      const res = await fetch('http://apigw:5000/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });
      if (res.ok) {
        // OTP入力画面へ遷移
        localStorage.setItem('register_email', email);
        window.location.href = 'otp.html';
      } else {
        errorMessage.textContent = '登録に失敗しました。';
      }
    } catch (err) {
      errorMessage.textContent = '通信エラーが発生しました。';
    }
  });

  function validateEmail(email) {
    // 簡易なメールアドレス形式チェック
    return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);
  }
}); 