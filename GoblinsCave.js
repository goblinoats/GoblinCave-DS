import ds from 'downstream';

export default function update({ selected, world }) {

    const goblinImg = "https://i.imgur.com/JeRSWq1.jpeg";

    const { tiles, mobileUnit } = selected || {};
    const selectedTile = tiles && tiles.length === 1 ? tiles[0] : undefined;
    const selectedBuilding = selectedTile?.building;

    const onSubmit = () => {

        const rob = Math.random();
        ds.log(rob);

        if (rob > 0.5) {
            const buildId = selectedBuilding.id.slice(-5);
            const bagId = ["0xb1c93f090000000",buildId,"0000000000eee2a52", Math.round(Math.random()*9999)].join('');
            const actions = (mobileUnit?.bags || []).flatMap(b => b.bag.slots.filter(slot => slot.balance > 0).map(slot => ({
                name: 'TRANSFER_ITEM_MOBILE_UNIT',
                args: [
                    mobileUnit.id,
                    [mobileUnit.id, selectedBuilding.id],
                    [b.key, Math.round(Math.random()*99999) + b.key],
                    [slot.key, slot.key],
                    [bagId,b.key.toString()].join(''),
                    slot.balance
                ]
            })));
            ds.dispatch(...actions);
        } else {
            const actions = selectedBuilding.bags?.flatMap((b,mobileUnitEquipSlot) => b ? b.bag.slots.filter(slot => slot.balance > 0).map(slot => ({
                name: 'TRANSFER_ITEM_MOBILE_UNIT',
                args: [
                    mobileUnit.id,
                    [selectedBuilding.id, mobileUnit.id],
                    [b.key, mobileUnitEquipSlot],
                    [slot.key, slot.key],
                    "0x000000000000000000000000000000000000000000000000",
                    slot.balance
                ]
            })) : null).filter(a => !!a);
            ds.dispatch(...actions);
        }
    }

    return {
        version: 1,
        components: [
            {
                type: 'building',
                id: 'Goblins Cave',
                title: 'Goblins Cave',
                summary: `A green goblin greets you with a friendly smile and continues to his tasks. The cave is decorated with scraps of curious garbage. There is a strange odor.`,
                content: [
                    {
                        id: 'default',
                        type: 'inline',
                        html: `
                        <div>
                            <img src="${goblinImg}" />
                            <button type="submit" style="width:100%; padding:5px; border-radius: 10px;">PLUNGE GOBLIN THINGY</button>
                        </div>
                        `,
                        submit: onSubmit,
                        buttons: [],
                    }
                ],
            },
        ],
    };
}

