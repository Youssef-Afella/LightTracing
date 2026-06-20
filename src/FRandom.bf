namespace LightTracing;

public class Randomf
{
	private uint32 state = 0;

	private uint32 nextRand()
	{
	    state = state * 747796405u + 2891336453u;
	    uint32 result = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
	    return (result >> 22u) ^ result;
	}

	public float nextFloat()
	{
		return (float)nextRand() / (float)uint32.MaxValue;
	}
}