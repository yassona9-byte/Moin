package aufgabe2_2;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class FormelsammlungTest {

    /** Erlaubte Abweichung bei Gleitkomma-Vergleichen. */
    private static final double DELTA = 1e-9;

    @Test
    void pqFormel() {
        // x^2 - 5x + 6 = 0  ->  x1 = 3, x2 = 2
        assertArrayEquals(new double[]{3.0, 2.0}, Formelsammlung.pqFormel(-5, 6), DELTA);
    }

    @Test
    void abcFormel() {
        // 2x^2 - 4x - 6 = 0  ->  x1 = 3, x2 = -1
        assertArrayEquals(new double[]{3.0, -1.0}, Formelsammlung.abcFormel(2, -4, -6), DELTA);
    }

    @Test
    void flaecheninhaltDreieck() {
        assertEquals(15.0, Formelsammlung.flaecheninhaltDreieck(6, 5), DELTA);
    }

    @Test
    void umfangDreieck() {
        assertEquals(12.0, Formelsammlung.umfangDreieck(3, 4, 5), DELTA);
    }

    @Test
    void flaecheninhaltRechteck() {
        assertEquals(12.0, Formelsammlung.flaecheninhaltRechteck(3, 4), DELTA);
    }

    @Test
    void umfangRechteck() {
        assertEquals(14.0, Formelsammlung.umfangRechteck(3, 4), DELTA);
    }

    @Test
    void flaecheninhaltParallelogramm() {
        assertEquals(20.0, Formelsammlung.flaecheninhaltParallelogramm(5, 4), DELTA);
    }

    @Test
    void umfangParallelogramm() {
        assertEquals(16.0, Formelsammlung.umfangParallelogramm(5, 3), DELTA);
    }

    @Test
    void flaecheninhaltTrapez() {
        // (a + c) / 2 * h = (6 + 4) / 2 * 3 = 15
        assertEquals(15.0, Formelsammlung.flaecheninhaltTrapez(6, 4, 3), DELTA);
    }

    @Test
    void umfangTrapez() {
        assertEquals(18.0, Formelsammlung.umfangTrapez(6, 4, 5, 3), DELTA);
    }

    @Test
    void flaecheninhaltKreis() {
        assertEquals(Math.PI * 4, Formelsammlung.flaecheninhaltKreis(2), DELTA);
    }

    @Test
    void umfangKreis() {
        assertEquals(2 * Math.PI * 2, Formelsammlung.umfangKreis(2), DELTA);
    }

    @Test
    void compare() {
        assertEquals(-1, Formelsammlung.compare(2, 5));
        assertEquals(0, Formelsammlung.compare(5, 5));
        assertEquals(1, Formelsammlung.compare(5, 2));
    }

    @Test
    void fakultaet() {
        assertEquals(1, Formelsammlung.fakultaet(0));
        assertEquals(1, Formelsammlung.fakultaet(1));
        assertEquals(120, Formelsammlung.fakultaet(5));
    }

    @Test
    void fibonacciFolge() {
        long[] erwartet = {0, 1, 1, 2, 3, 5, 8, 13};
        assertArrayEquals(erwartet, Formelsammlung.fibonacciFolge(8));
    }

    @Test
    void vektoraddition() {
        double[] a = {1, 2, 3};
        double[] b = {4, 5, 6};
        assertArrayEquals(new double[]{5, 7, 9}, Formelsammlung.vektoraddition(a, b), DELTA);
    }

    @Test
    void vektorsubtraktion() {
        double[] a = {4, 5, 6};
        double[] b = {1, 2, 3};
        assertArrayEquals(new double[]{3, 3, 3}, Formelsammlung.vektorsubtraktion(a, b), DELTA);
    }

    @Test
    void skalarmultiplikation() {
        double[] v = {1, 2, 3};
        assertArrayEquals(new double[]{2, 4, 6}, Formelsammlung.skalarmultiplikation(2, v), DELTA);
    }

    @Test
    void laengeDesVektors() {
        // |(3, 4)| = 5
        assertEquals(5.0, Formelsammlung.laengeDesVektors(new double[]{3, 4}), DELTA);
    }

    @Test
    void matrizenAddieren() {
        double[][] a = {{1, 2}, {3, 4}};
        double[][] b = {{5, 6}, {7, 8}};
        double[][] erwartet = {{6, 8}, {10, 12}};
        assertArrayEquals(erwartet, Formelsammlung.matrizenAddieren(a, b));
    }

    @Test
    void matrizenSubtrahieren() {
        double[][] a = {{5, 6}, {7, 8}};
        double[][] b = {{1, 2}, {3, 4}};
        double[][] erwartet = {{4, 4}, {4, 4}};
        assertArrayEquals(erwartet, Formelsammlung.matrizenSubtrahieren(a, b));
    }

    @Test
    void matrizenMultiplikation() {
        double[][] a = {{1, 2}, {3, 4}};
        double[][] b = {{5, 6}, {7, 8}};
        // [[1*5+2*7, 1*6+2*8], [3*5+4*7, 3*6+4*8]] = [[19, 22], [43, 50]]
        double[][] erwartet = {{19, 22}, {43, 50}};
        assertArrayEquals(erwartet, Formelsammlung.matrizenMultiplikation(a, b));
    }

    @Test
    void matrixTransponieren() {
        double[][] m = {{1, 2, 3}, {4, 5, 6}};
        double[][] erwartet = {{1, 4}, {2, 5}, {3, 6}};
        assertArrayEquals(erwartet, Formelsammlung.matrixTransponieren(m));
    }
}
