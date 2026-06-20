namespace LightTracing;

static class Scenes
{

	public static SceneElement[] scene1 = new SceneElement[]
	(
		SceneElement(0, Vec2(500.0000f, 350.0000f), 80.0f, 1.5f),
		SceneElement(0, Vec2(700.0000f, 350.0000f), 80.0f, 1.5f),
		SceneElement(0, Vec2(561.8034f, 540.2113f), 80.0f, 1.5f),
		SceneElement(0, Vec2(338.1966f, 467.5570f), 80.0f, 1.5f),
		SceneElement(0, Vec2(338.1966f, 232.4429f), 80.0f, 1.5f),
		SceneElement(0, Vec2(561.8034f, 159.7887f), 80.0f, 1.5f)
	)
	~ delete _;

	public static SceneElement[] scene2 = new SceneElement[]
	(
		SceneElement(2, Vec2(500.0000f, 350.0000f), 150.0f, 1.5f),
	)
	~ delete _;

	public static Scene[] scenes = new Scene[](
		Scene(scene1),
		Scene(scene2)
	)
	~ delete _;


	public struct Scene
	{
		public SceneElement[] elements;

		public this(SceneElement[] elements)
		{
			this.elements = elements;
		}
	}

	public struct SceneElement
	{
		public int type;//0: Disk | 1: Box | 2: Triangle
		public Vec2 position;
		public float size;
		public float ior;

		public this(int type, Vec2 position, float size, float ior)
		{
			this.type = type;
			this.position = position;
			this.size = size;
			this.ior = ior;
		}
	}

}