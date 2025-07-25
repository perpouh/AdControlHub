document.addEventListener('DOMContentLoaded', function() {
  const form = document.getElementById('otp-form');
  const otpInput = document.getElementById('otp');
  const emailInput = document.getElementById('email');
  const errorMessage = document.getElementById('error-message');
  let failCount = 0;

  // メールアドレスをlocalStorageから取得してhiddenにセット
  const email = localStorage.getItem('register_email');
  if (!email) {
    window.location.href = 'index.html';
    return;
  }
  emailInput.value = email;

  form.addEventListener('submit', async function(e) {
    e.preventDefault();
    errorMessage.textContent = '';
    const otp = otpInput.value.trim().toUpperCase();
    if (!/^[A-HJ-NP-Z2-9]{6}$/.test(otp)) {
      errorMessage.textContent = '認証コードは6桁の英数字（I, O, 1, 0を除く）で入力してください。';
      return;
    }
    try {
      const res = await fetch('http://apigw:5000/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, otp })
      });
      if (res.ok) {
        // 認証成功
        localStorage.removeItem('register_email');
        window.location.href = 'https://example.com';
      } else {
        failCount++;
        if (failCount >= 3) {
          localStorage.removeItem('register_email');
          alert('3回間違えたため、最初からやり直してください。');
          window.location.href = 'index.html';
        } else {
          errorMessage.textContent = '認証コードが正しくありません。再度入力してください。';
        }
      }
    } catch (err) {
      errorMessage.textContent = '通信エラーが発生しました。';
    }
  });
}); 