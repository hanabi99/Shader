using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Test : MonoBehaviour
{
    private RectTransform _rectTransform;
    [SerializeField]
    private Button bigButton;

    void Start()
    {
        Debug.Log(Application.dataPath);
        byte flags = 0; // 用一个字节存储8个bool值

        // 设置第3位为true（从0开始计数）
        flags = SetBit(flags, 2, true);

        // 检查第3位是否为true
        bool isSet = GetBit(flags, 2);
        Console.WriteLine("第3位是否为true: " + isSet);

        // 设置第3位为false
        flags = SetBit(flags, 2, false);

        // 再次检查第3位是否为true
        isSet = GetBit(flags, 2);
        Console.WriteLine("第3位是否为true: " + isSet);
        
        
        
        _rectTransform = GetComponent<RectTransform>();
        bigButton.onClick.AddListener(() => DebugLog("Big Button Clicked"));
        Debug.Log(_rectTransform.position);
        Debug.Log(_rectTransform.localPosition);
        Debug.Log(transform.localPosition);
        Debug.Log(transform.position);
        IAnimal dog = new Dog();
        IAnimal cat = new Cat();
        CheckType(dog);
    }
    // 设置指定位的值
    static byte SetBit(byte flags, int bitIndex, bool value)
    {
        if (value)
        {
            // 使用位或操作设置指定位为1
            flags |= (byte)(1 << bitIndex);
        }
        else
        {
            // 使用位与操作和位非操作设置指定位为0
            flags &= (byte)~(1 << bitIndex);
        }
        return flags;
    }
    
    // 获取指定位的值
    static bool GetBit(byte flags, int bitIndex)
    {
        // 使用位与操作检查指定位是否为1
        return (flags & (1 << bitIndex)) != 0;
    }

    public void DebugLog(string message)
    {
        Debug.Log(message);
    }

    void CheckType(IAnimal animal)
    {
        if (animal is Dog)
        {
            var dog = animal as Dog?;
            Debug.Log(animal == (IAnimal)dog);
        }
        
        if (animal is Cat)
        {
            
        }
    }
}

public interface IAnimal
{
    
}

public struct Dog : IAnimal
{
}

public struct Cat : IAnimal
{
}