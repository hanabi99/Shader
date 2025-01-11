using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProceduralTexture : MonoBehaviour
{
    //程序纹理的宽高
    public int textureWidth = 256;
    public int textureHeight = 256;
    //国际象棋棋盘格的行列数
    public int tileCount = 8;
    //棋盘格的两种颜色
    public Color color1 = Color.white;
    public Color color2 = Color.black;


    // Start is called before the first frame update
    private void Start()
    {
        UpdateTexture();
    }

    /// <summary>
    /// 更新纹理
    /// </summary>
    public void UpdateTexture()
    {
        //更具对应的纹理宽高来new一个2D纹理对象
        var tex = new Texture2D(textureWidth, textureHeight);
        for (var y = 0; y < textureHeight; y++)
        {
            for (var x = 0; x < textureWidth; x++)
            {
                //首先需要知道 格子的宽高是多少
                //textureWidth / tileCount = 格子的宽
                //textureHeight / tileCount = 格子的高

                // x / 格子的宽（32）= 当前x所在格子编号
                // y / 格子的高 (32) = 当前y所在格子编号

                //要判断一个数 是偶数还是奇数 直接对2取余 如果是0 则为偶数 如果为1 则为奇数
                //判断 x 和 y 方向 格子索引 是否同奇 或者 同偶
                var valueX = x / (textureWidth / tileCount) % 2;
                var valueY = y / (textureHeight / tileCount) % 2;
                if( valueX == valueY )
                    tex.SetPixel(x, y, color1);
                else
                    tex.SetPixel(x, y, color2);
            }
        }
        //应用像素的变化
        tex.Apply();

        var renderer = this.GetComponent<Renderer>();
        if(renderer != null)
        {
            //得到渲染器组件中的材质球 并且修改它的主纹理
            renderer.sharedMaterial.mainTexture = tex;
        }
    }
}
