// LoginForm — structural outline

export default function LoginForm() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <section className="w-full max-w-sm bg-white border border-gray-200 rounded-2xl p-10 shadow-sm">
        <header className="mb-6">
          {/* Logo: top of the card, small — 32–40px. Reinforces brand before the user does anything */}
          <div className="w-9 h-9 bg-gray-900 rounded-lg flex items-center justify-center mb-4">
            <span className="text-indigo-300 text-sm font-bold">A</span>
          </div>
          {/* Heading: one clear action-oriented line. "Welcome back" outperforms "Login" in conversion */}
          <h1 className="text-xl font-semibold text-gray-900 tracking-tight mb-1">
            Welcome back
          </h1>
          {/* Sign-up link: secondary, below the heading — don't compete with the primary form action */}
          <p className="text-sm text-gray-500">
            No account?{" "}
            <a
              href="/signup"
              className="text-indigo-600 font-medium hover:underline"
            >
              Sign up free
            </a>
          </p>
        </header>

        <form method="POST" action="/login" noValidate>
          <fieldset className="mb-5 border-none p-0">
            <legend className="sr-only">Account credentials</legend>

            <div className="mb-4">
              {/* Label: ALL CAPS small text above the field — creates visual hierarchy without size change */}
              <label
                htmlFor="email"
                className="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1.5"
              >
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                placeholder="you@example.com"
                className="w-full h-11 px-3.5 border border-gray-200 rounded-lg text-sm bg-gray-50 text-gray-900 placeholder:text-gray-400 outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/10 transition"
              />
            </div>

            <div className="mb-5">
              <label
                htmlFor="password"
                className="block text-xs font-medium text-gray-500 uppercase tracking-wide mb-1.5"
              >
                Password
              </label>
              {/* Eye toggle: right-aligned inside the field — never place it outside, breaks the visual unit */}
              <div className="relative">
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  placeholder="••••••••"
                  className="w-full h-11 px-3.5 pr-11 border border-gray-200 rounded-lg text-sm bg-gray-50 text-gray-900 placeholder:text-gray-400 outline-none focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/10 transition"
                />
                <button
                  type="button"
                  aria-label="Toggle password visibility"
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  👁
                </button>
              </div>
            </div>
          </fieldset>

          {/* Remember me + Forgot: justify-between keeps these at opposite ends of the same row */}
          <div className="flex items-center justify-between mb-6">
            <label
              htmlFor="remember"
              className="flex items-center gap-2 text-sm text-gray-500 cursor-pointer"
            >
              <input
                id="remember"
                name="remember"
                type="checkbox"
                className="accent-indigo-600 w-3.5 h-3.5"
              />
              Remember me
            </label>
            {/* Forgot password: low visual weight — it's an escape hatch, not a primary action */}
            <a
              href="/forgot-password"
              className="text-sm text-indigo-600 font-medium hover:underline"
            >
              Forgot password?
            </a>
          </div>

          {/* Primary CTA: full width, high contrast — the single most important action on this screen */}
          <button
            type="submit"
            className="w-full h-11 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.98] text-white text-sm font-semibold rounded-lg transition mb-5"
          >
            Sign in
          </button>
        </form>

        {/* Divider: use "or continue with" not just "or" — more descriptive for screen readers */}
        <div role="separator" className="flex items-center gap-3 mb-5">
          <span className="flex-1 h-px bg-gray-200"></span>
          <span className="text-xs text-gray-400">or continue with</span>
          <span className="flex-1 h-px bg-gray-200"></span>
        </div>

        {/* SSO button: ghost/outline style — visually subordinate to the primary Sign in CTA */}
        <form method="POST" action="/auth/google">
          <button
            type="submit"
            className="w-full h-11 flex items-center justify-center gap-2.5 border border-gray-200 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 transition"
          >
            {/* Provider logo: 16px, left of label — users scan for the logo before reading the text */}
            <span aria-hidden="true">G</span>
            Continue with Google
          </button>
        </form>
      </section>
    </main>
  );
}
