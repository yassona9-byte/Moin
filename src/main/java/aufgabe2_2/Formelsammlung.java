package aufgabe2_2;

/**
 * Eine kleine Formelsammlung mit gängigen mathematischen Formeln
 * (Geometrie, Vektoren, Matrizen und ein paar Zahlenfolgen).
 */
public class Formelsammlung {

    // ----- Gleichungen -----

    /**
     * Löst eine quadratische Gleichung der Form x^2 + p*x + q = 0.
     *
     * @return Array mit den beiden Lösungen {x1, x2}
     */
    public static double[] pqFormel(double p, double q) {
        double diskriminante = (p / 2) * (p / 2) - q;
        double wurzel = Math.sqrt(diskriminante);
        double x1 = -p / 2 + wurzel;
        double x2 = -p / 2 - wurzel;
        return new double[]{x1, x2};
    }

    /**
     * Löst eine quadratische Gleichung der Form a*x^2 + b*x + c = 0.
     *
     * @return Array mit den beiden Lösungen {x1, x2}
     */
    public static double[] abcFormel(double a, double b, double c) {
        double diskriminante = b * b - 4 * a * c;
        double wurzel = Math.sqrt(diskriminante);
        double x1 = (-b + wurzel) / (2 * a);
        double x2 = (-b - wurzel) / (2 * a);
        return new double[]{x1, x2};
    }

    // ----- Dreieck -----

    /** Flächeninhalt eines Dreiecks: A = 0.5 * Grundseite * Höhe. */
    public static double flaecheninhaltDreieck(double grundseite, double hoehe) {
        return 0.5 * grundseite * hoehe;
    }

    /** Umfang eines Dreiecks: U = a + b + c. */
    public static double umfangDreieck(double a, double b, double c) {
        return a + b + c;
    }

    // ----- Rechteck -----

    /** Flächeninhalt eines Rechtecks: A = a * b. */
    public static double flaecheninhaltRechteck(double a, double b) {
        return a * b;
    }

    /** Umfang eines Rechtecks: U = 2 * (a + b). */
    public static double umfangRechteck(double a, double b) {
        return 2 * (a + b);
    }

    // ----- Parallelogramm -----

    /** Flächeninhalt eines Parallelogramms: A = a * h. */
    public static double flaecheninhaltParallelogramm(double a, double hoehe) {
        return a * hoehe;
    }

    /** Umfang eines Parallelogramms: U = 2 * (a + b). */
    public static double umfangParallelogramm(double a, double b) {
        return 2 * (a + b);
    }

    // ----- Trapez -----

    /** Flächeninhalt eines Trapezes: A = (a + c) / 2 * h. */
    public static double flaecheninhaltTrapez(double a, double c, double hoehe) {
        return (a + c) / 2 * hoehe;
    }

    /** Umfang eines Trapezes: U = a + b + c + d. */
    public static double umfangTrapez(double a, double b, double c, double d) {
        return a + b + c + d;
    }

    // ----- Kreis -----

    /** Flächeninhalt eines Kreises: A = pi * r^2. */
    public static double flaecheninhaltKreis(double radius) {
        return Math.PI * radius * radius;
    }

    /** Umfang eines Kreises: U = 2 * pi * r. */
    public static double umfangKreis(double radius) {
        return 2 * Math.PI * radius;
    }

    // ----- Zahlen / Folgen -----

    /**
     * Vergleicht zwei Zahlen.
     *
     * @return -1 wenn a < b, 0 wenn a == b, 1 wenn a > b
     */
    public static int compare(double a, double b) {
        if (a < b) {
            return -1;
        }
        if (a > b) {
            return 1;
        }
        return 0;
    }

    /** Fakultät: n! = 1 * 2 * ... * n. (0! = 1) */
    public static long fakultaet(int n) {
        if (n < 0) {
            throw new IllegalArgumentException("n darf nicht negativ sein");
        }
        long ergebnis = 1;
        for (int i = 2; i <= n; i++) {
            ergebnis *= i;
        }
        return ergebnis;
    }

    /**
     * Liefert die ersten n Glieder der Fibonacci-Folge,
     * beginnend mit 0, 1, 1, 2, 3, ...
     */
    public static long[] fibonacciFolge(int n) {
        long[] folge = new long[n];
        for (int i = 0; i < n; i++) {
            if (i == 0) {
                folge[i] = 0;
            } else if (i == 1) {
                folge[i] = 1;
            } else {
                folge[i] = folge[i - 1] + folge[i - 2];
            }
        }
        return folge;
    }

    // ----- Vektoren -----

    /** Addiert zwei Vektoren komponentenweise. */
    public static double[] vektoraddition(double[] a, double[] b) {
        double[] ergebnis = new double[a.length];
        for (int i = 0; i < a.length; i++) {
            ergebnis[i] = a[i] + b[i];
        }
        return ergebnis;
    }

    /** Subtrahiert zwei Vektoren komponentenweise (a - b). */
    public static double[] vektorsubtraktion(double[] a, double[] b) {
        double[] ergebnis = new double[a.length];
        for (int i = 0; i < a.length; i++) {
            ergebnis[i] = a[i] - b[i];
        }
        return ergebnis;
    }

    /** Multipliziert einen Vektor mit einem Skalar. */
    public static double[] skalarmultiplikation(double skalar, double[] v) {
        double[] ergebnis = new double[v.length];
        for (int i = 0; i < v.length; i++) {
            ergebnis[i] = skalar * v[i];
        }
        return ergebnis;
    }

    /** Länge (Betrag) eines Vektors: sqrt(x1^2 + x2^2 + ...). */
    public static double laengeDesVektors(double[] v) {
        double summe = 0;
        for (double komponente : v) {
            summe += komponente * komponente;
        }
        return Math.sqrt(summe);
    }

    // ----- Matrizen -----

    /** Addiert zwei Matrizen komponentenweise. */
    public static double[][] matrizenAddieren(double[][] a, double[][] b) {
        double[][] ergebnis = new double[a.length][a[0].length];
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < a[i].length; j++) {
                ergebnis[i][j] = a[i][j] + b[i][j];
            }
        }
        return ergebnis;
    }

    /** Subtrahiert zwei Matrizen komponentenweise (a - b). */
    public static double[][] matrizenSubtrahieren(double[][] a, double[][] b) {
        double[][] ergebnis = new double[a.length][a[0].length];
        for (int i = 0; i < a.length; i++) {
            for (int j = 0; j < a[i].length; j++) {
                ergebnis[i][j] = a[i][j] - b[i][j];
            }
        }
        return ergebnis;
    }

    /** Multipliziert zwei Matrizen (a * b). */
    public static double[][] matrizenMultiplikation(double[][] a, double[][] b) {
        int zeilen = a.length;
        int spalten = b[0].length;
        int gemeinsam = b.length;
        double[][] ergebnis = new double[zeilen][spalten];
        for (int i = 0; i < zeilen; i++) {
            for (int j = 0; j < spalten; j++) {
                double summe = 0;
                for (int k = 0; k < gemeinsam; k++) {
                    summe += a[i][k] * b[k][j];
                }
                ergebnis[i][j] = summe;
            }
        }
        return ergebnis;
    }

    /** Transponiert eine Matrix (Zeilen und Spalten tauschen). */
    public static double[][] matrixTransponieren(double[][] m) {
        double[][] ergebnis = new double[m[0].length][m.length];
        for (int i = 0; i < m.length; i++) {
            for (int j = 0; j < m[i].length; j++) {
                ergebnis[j][i] = m[i][j];
            }
        }
        return ergebnis;
    }
}
