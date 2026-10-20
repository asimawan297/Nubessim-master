const { onRequest } = require("firebase-functions/v2/https");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

const STRIPE_FX_VERSION = "2026-02-25.preview";

const COUNTRY_CURRENCY = {
    AD: "eur", AE: "aed", AF: "afn", AG: "xcd", AI: "xcd", AL: "all",
    AM: "amd", AO: "aoa", AT: "eur", AU: "aud", AW: "awg", AX: "eur",
    AZ: "azn", BA: "bam", BB: "bbd", BD: "bdt", BE: "eur", BF: "xof",
    BG: "eur", BH: "bhd", BI: "bif", BJ: "xof", BL: "eur", BM: "bmd",
    BN: "bnd", BO: "bob", BR: "brl", BS: "bsd", BT: "inr", BW: "bwp",
    BZ: "bzd", CA: "cad", CF: "xaf", CG: "xaf", CH: "chf", CI: "xof",
    CK: "nzd", CL: "clp", CM: "xaf", CN: "cny", CO: "cop", CR: "crc",
    CV: "cve", CW: "ang", CY: "eur", CZ: "czk", DE: "eur", DJ: "djf",
    DK: "dkk", DM: "xcd", DO: "dop", DZ: "dzd", EE: "eur", ES: "eur",
    FI: "eur", FK: "fkp", FR: "eur", GA: "xaf", GB: "gbp", GD: "xcd",
    GE: "gel", GF: "eur", GG: "gbp", GI: "gip", GM: "gmd", GN: "gnf",
    GP: "eur", GQ: "xaf", GR: "eur", GS: "gbp", GT: "gtq", GW: "xof",
    GY: "gyd", HK: "hkd", HN: "hnl", HR: "eur", HT: "htg", HU: "huf",
    ID: "idr", IE: "eur", IL: "ils", IM: "gbp", IN: "inr", IO: "gbp",
    IS: "isk", IT: "eur", JE: "gbp", JM: "jmd", JO: "jod", JP: "jpy",
    KE: "kes", KG: "kgs", KH: "khr", KI: "aud", KN: "xcd", KR: "krw",
    KW: "kwd", KY: "kyd", KZ: "kzt", LC: "xcd", LI: "chf", LK: "lkr",
    LR: "lrd", LT: "eur", LU: "eur", LV: "eur", MA: "mad", MC: "eur",
    MD: "mdl", ME: "eur", MF: "eur", MG: "mga", MK: "mkd", ML: "xof",
    MN: "mnt", MO: "mop", MQ: "eur", MS: "xcd", MT: "eur", MU: "mur",
    MV: "mvr", MX: "mxn", MY: "myr", MZ: "mzn", NA: "nad", NC: "xpf",
    NE: "xof", NL: "eur", NO: "nok", NP: "npr", NR: "aud", NU: "nzd",
    NZ: "nzd", OM: "omr", PA: "pab", PE: "pen", PF: "xpf", PH: "php",
    PK: "pkr", PL: "pln", PM: "eur", PN: "gbp", PT: "eur", QA: "qar",
    RE: "eur", RO: "ron", RS: "rsd", RW: "rwf", SA: "sar", SE: "sek",
    SG: "sgd", SH: "shp", SI: "eur", SK: "eur", SM: "eur", SN: "xof",
    ST: "std", SX: "ang", TD: "xaf", TG: "xof", TH: "thb", TJ: "tjs",
    TN: "tnd", TR: "try", TT: "ttd", TV: "aud", TW: "twd", TZ: "tzs",
    UA: "uah", UG: "ugx", UY: "uyu", UZ: "uzs", VA: "eur", VC: "xcd",
    VN: "vnd", WF: "xpf", XK: "eur", YE: "yer", YT: "eur", ZA: "zar",
    ZM: "zmw",
};

function applyCors(req, res) {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    if (req.method === "OPTIONS") {
        res.status(204).send("");
        return true;
    }
    return false;
}

function currencyFromBody(body) {
    const requested = String(body.currency || "").trim().toLowerCase();
    if (/^[a-z]{3}$/.test(requested)) return requested;
    const country = String(body.country || "").trim().toUpperCase();
    return COUNTRY_CURRENCY[country] || "usd";
}

async function stripeForm(path, params) {
    const body = new URLSearchParams();
    Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null && value !== "") {
            body.append(key, String(value));
        }
    });
    const response = await fetch(`https://api.stripe.com/v1/${path}`, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${process.env.STRIPE_SECRET_KEY}`,
            "Content-Type": "application/x-www-form-urlencoded",
            "Stripe-Version": STRIPE_FX_VERSION,
        },
        body,
    });
    const data = await response.json();
    if (!response.ok) {
        const message = data.error && data.error.message
            ? data.error.message
            : "Stripe request failed";
        const error = new Error(message);
        error.status = response.status;
        throw error;
    }
    return data;
}

exports.fxQuote = onRequest(async (req, res) => {
    try {
        if (applyCors(req, res)) return;
        const currency = currencyFromBody(req.body || {});
        if (currency === "usd") {
            return res.status(200).json({
                quoteId: null,
                currency: "USD",
                exchangeRate: 1,
                expiresAt: null,
            });
        }
        // Settlement currency is USD. exchange_rate is dollars per 1 local unit,
        // locked for a day, which is the quote the website prices from.
        const quote = await stripeForm("fx_quotes", {
            to_currency: "usd",
            "from_currencies[]": currency,
            lock_duration: "day",
        });
        const rate = quote.rates && quote.rates[currency]
            ? Number(quote.rates[currency].exchange_rate)
            : NaN;
        if (!Number.isFinite(rate) || rate <= 0) {
            return res.status(502).json({ error: "Stripe did not return a USD rate" });
        }
        return res.status(200).json({
            quoteId: quote.id,
            currency: currency.toUpperCase(),
            exchangeRate: rate,
            rateBasis: "usd_per_unit",
            expiresAt: quote.lock_expires_at || null,
        });
    } catch (error) {
        return res.status(error.status || 500).json({ error: error.message });
    }
});

exports.createPaymentIntent = onRequest(async (req, res) => {
    try {
        if (applyCors(req, res)) return;
        const { amount, currency, whatsapp_number, fx_quote } = req.body || {};
        if (!amount) {
            return res.status(400).json({ error: "Amount is required" });
        }
        if (!whatsapp_number || !String(whatsapp_number).trim()) {
            return res.status(400).json({ error: "whatsapp_number is required" });
        }
        const chargeCurrency = (currency || "usd").toLowerCase();
        const whatsappNumber = String(whatsapp_number).trim();

        let paymentIntent;
        if (fx_quote) {
            paymentIntent = await stripeForm("payment_intents", {
                amount: Math.round(Number(amount)),
                currency: chargeCurrency,
                fx_quote,
                "payment_method_types[]": "card",
                "payment_method_options[card][request_three_d_secure]": "any",
                "metadata[whatsapp_number]": whatsappNumber,
            });
        } else {
            paymentIntent = await stripe.paymentIntents.create({
                amount: amount,
                currency: chargeCurrency,
                payment_method_types: ["card"],
                payment_method_options: {
                    card: {
                        request_three_d_secure: "any",
                    },
                },
                metadata: {
                    whatsapp_number: whatsappNumber,
                },
            });
        }
        return res.status(200).json({ clientSecret: paymentIntent.client_secret });
    } catch (error) {
        return res.status(error.status || 500).json({ error: error.message });
    }
});
