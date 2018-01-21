import java.nio.charset.StandardCharsets;

public class AvroFingerprint {
    public static void main(String args[]) throws Exception {
        if (args.length > 0) {
            long fp = fingerprint64(args[0].getBytes(StandardCharsets.UTF_8));
            // System.out.format("fingerprint: %s%n", Long.toHexString(fp));
            System.out.format("fingerprint: %s %d%n", Long.toHexString(fp), fp);
        }
    }

    static long fingerprint64(byte[] buf) {
        if (FP_TABLE == null) initFPTable();
        long fp = EMPTY;
        for (int i = 0; i < buf.length; i++)  {
            // System.out.format("%d %s %s %s%n", i, Long.toHexString(fp), Long.toHexString(fp >>> 8), Long.toHexString(fp ^ buf[i]));
            fp = (fp >>> 8) ^ FP_TABLE[(int)(fp ^ buf[i]) & 0xff];
        }
        return fp;
    }

    static long EMPTY = 0xc15d213aa4d7a795L;
    static long[] FP_TABLE = null;

    static void initFPTable() {
        FP_TABLE = new long[256];
        for (int i = 0; i < 256; i++) {
            long fp = i;
            for (int j = 0; j < 8; j++)
                fp = (fp >>> 1) ^ (EMPTY & -(fp & 1L));
            FP_TABLE[i] = fp;
            System.out.format("fp_table(%d) -> 16#%s;%n", i, Long.toHexString(fp));
        }
    }
}
